note
	description: "[
		Converter between JSON_OBJECT and S driven by reflection.
		Attributes whose name and type match a JSON field flow
		automatically in both directions; only mismatches (renames,
		type changes, store-only attributes) are declared, once, in
		`correct_mismatches` — {MISMATCH_CORRECTOR}'s idea applied
		to representation/store conversion.
		Natural types: INTEGER, BOOLEAN, STRING. Reference attributes
		must be initialized by the factory (the schema check reads
		them to learn their type).
		`make` fails fast — at wiring time, not mid-request — on any
		attribute neither matched nor declared.
	]"

class
	RESTLY_REFLECTIVE_CONVERTER [S -> ANY]

inherit
	RESTLY_CONVERTER [JSON_OBJECT, S]

create
	make

feature {NONE} -- Initialization

	make (a_factory: FUNCTION [S])
			-- Converter minting fresh stores via `a_factory`; collect
			-- mismatch declarations, then verify every attribute of S
			-- is matched, renamed, converted or skipped.
		do
			factory := a_factory
			create renamings.make (0)
			create skips.make (0)
			create from_json_converters.make (0)
			create to_json_converters.make (0)
			correct_mismatches
			check_schema
		ensure
			error_500_all_attributes_accounted: True
					-- TODO(owner): contract
					-- suggested: every attribute of S is matched,
					-- renamed, converted, or skipped — no silent gaps
		end

feature -- Conversion

	to_store (a_representation: JSON_OBJECT): S
			-- <Precursor>
			-- Fresh store from `factory`; absent JSON fields keep
			-- the factory defaults.
		local
			l_fields: REFLECTED_REFERENCE_OBJECT
			i: INTEGER
			l_name: STRING
		do
			Result := factory.item ([])
			create l_fields.make (Result)
			from
				i := 1
			until
				i > l_fields.field_count
			loop
				l_name := l_fields.field_name (i)
				if skips.has (l_name) then
						-- Store-only attribute: keep the factory default.
				elseif attached from_json_converters.item (l_name) as l_convert then
					if attached a_representation.item (json_key (l_name)) as l_value then
						l_convert (l_fields, i, l_value)
					end
				else
					inspect l_fields.field_type (i)
					when {REFLECTOR_CONSTANTS}.integer_32_type then
						if attached {JSON_NUMBER} a_representation.item (json_key (l_name)) as l_number then
							l_fields.set_integer_32_field (i, l_number.integer_64_item.to_integer_32)
						end
					when {REFLECTOR_CONSTANTS}.boolean_type then
						if attached {JSON_BOOLEAN} a_representation.item (json_key (l_name)) as l_boolean then
							l_fields.set_boolean_field (i, l_boolean.item)
						end
					else
						if attached {JSON_STRING} a_representation.item (json_key (l_name)) as l_string then
							l_fields.set_reference_field (i, l_string.unescaped_string_8)
						end
					end
				end
				i := i + 1
			end
		end

	to_representation (a_store: S): JSON_OBJECT
			-- <Precursor>
			-- One JSON field per non-skipped attribute of `a_store`.
		local
			l_fields: REFLECTED_REFERENCE_OBJECT
			i: INTEGER
			l_name: STRING
			l_key: JSON_STRING
		do
			create l_fields.make (a_store)
			create Result.make_with_capacity (l_fields.field_count)
			from
				i := 1
			until
				i > l_fields.field_count
			loop
				l_name := l_fields.field_name (i)
				if skips.has (l_name) then
						-- Store-only attribute: never travels.
				else
					l_key := json_key (l_name)
					if attached to_json_converters.item (l_name) as l_convert then
						Result.put (l_convert (l_fields, i), l_key)
					else
						inspect l_fields.field_type (i)
						when {REFLECTOR_CONSTANTS}.integer_32_type then
							Result.put_integer (l_fields.integer_32_field (i), l_key)
						when {REFLECTOR_CONSTANTS}.boolean_type then
							Result.put_boolean (l_fields.boolean_field (i), l_key)
						else
							if attached {READABLE_STRING_GENERAL} l_fields.field (i) as l_string then
								Result.put_string (l_string, l_key)
							end
						end
					end
				end
				i := i + 1
			end
		end

feature {NONE} -- Mismatch declarations

	correct_mismatches
			-- Declare the deviations between S's schema and the JSON
			-- schema. Default: none — every attribute matches its JSON
			-- field by name and type ("attribute not changed").
		do
		end

	rename_field (a_attribute, a_json_key: STRING)
			-- "Attribute renamed": `a_attribute` travels in JSON as
			-- `a_json_key`.
		require
			error_500_attribute_exists: True
					-- TODO(owner): contract
					-- suggested: S has an attribute named `a_attribute`
		do
			renamings.force (a_json_key, a_attribute)
		end

	skip_field (a_attribute: STRING)
			-- "Attribute removed" (from the representation's view):
			-- `a_attribute` never travels in JSON.
		require
			error_500_attribute_exists: True
					-- TODO(owner): contract
		do
			skips.force (True, a_attribute)
		end

	convert_boolean_integer_field (a_attribute: STRING;
			a_to_store: FUNCTION [BOOLEAN, INTEGER];
			a_to_representation: FUNCTION [INTEGER, BOOLEAN])
			-- "Attribute type changed": `a_attribute` is INTEGER in the
			-- store, boolean in JSON; both directions declared together.
			-- ponytail: only sugar pair needed today; add a sibling
			-- feature per (json type, attribute type) pair when a
			-- resource needs one.
		require
			error_500_attribute_exists: True
					-- TODO(owner): contract
		do
			from_json_converters.force (
				agent (a_fields: REFLECTED_REFERENCE_OBJECT; i: INTEGER; a_value: JSON_VALUE; a_convert: FUNCTION [BOOLEAN, INTEGER])
					do
						if attached {JSON_BOOLEAN} a_value as l_boolean then
							a_fields.set_integer_32_field (i, a_convert (l_boolean.item))
						end
					end (?, ?, ?, a_to_store),
				a_attribute)
			to_json_converters.force (
				agent (a_fields: REFLECTED_REFERENCE_OBJECT; i: INTEGER; a_convert: FUNCTION [INTEGER, BOOLEAN]): JSON_VALUE
					do
						create {JSON_BOOLEAN} Result.make (a_convert (a_fields.integer_32_field (i)))
					end (?, ?, a_to_representation),
				a_attribute)
		end

feature {NONE} -- Implementation

	factory: FUNCTION [S]
			-- Mints the fresh store `to_store` fills.

	renamings: STRING_TABLE [STRING]
			-- Attribute name -> JSON key.

	skips: STRING_TABLE [BOOLEAN]
			-- Attributes that never travel in JSON.

	from_json_converters: STRING_TABLE [PROCEDURE [REFLECTED_REFERENCE_OBJECT, INTEGER, JSON_VALUE]]
			-- Attribute name -> JSON-to-field direction of a type change.

	to_json_converters: STRING_TABLE [FUNCTION [REFLECTED_REFERENCE_OBJECT, INTEGER, JSON_VALUE]]
			-- Attribute name -> field-to-JSON direction; always declared
			-- together with `from_json_converters` by the convert_* sugar.

	json_key (a_attribute: READABLE_STRING_GENERAL): STRING
			-- JSON field name for `a_attribute`: its declared rename,
			-- or the attribute name itself.
		do
			if attached renamings.item (a_attribute) as l_renamed then
				Result := l_renamed
			else
				Result := a_attribute.out
			end
		end

	check_schema
			-- Raise unless every attribute of S is naturally mappable
			-- or declared, and every declaration names a real attribute.
		local
			l_fields: REFLECTED_REFERENCE_OBJECT
			i: INTEGER
			l_name: STRING
			l_known: STRING_TABLE [BOOLEAN]
		do
			create l_fields.make (factory.item ([]))
			create l_known.make (l_fields.field_count)
			from
				i := 1
			until
				i > l_fields.field_count
			loop
				l_name := l_fields.field_name (i)
				l_known.force (True, l_name)
				if not (skips.has (l_name) or from_json_converters.has (l_name)) then
					inspect l_fields.field_type (i)
					when {REFLECTOR_CONSTANTS}.integer_32_type, {REFLECTOR_CONSTANTS}.boolean_type then
							-- Naturally mappable.
					else
						if not attached {READABLE_STRING_GENERAL} l_fields.field (i) then
							raise_schema_error (l_name, "is neither STRING, INTEGER, BOOLEAN nor declared in correct_mismatches")
						end
					end
				end
				i := i + 1
			end
			check_declared_exist (renamings.current_keys, l_known)
			check_declared_exist (skips.current_keys, l_known)
			check_declared_exist (from_json_converters.current_keys, l_known)
		end

	check_declared_exist (a_declared: ITERABLE [READABLE_STRING_GENERAL]; a_known: STRING_TABLE [BOOLEAN])
			-- Raise if any of `a_declared` is not an attribute of S.
		do
			across a_declared as l_name loop
				if not a_known.has (l_name) then
					raise_schema_error (l_name.out, "is declared in correct_mismatches but is not an attribute")
				end
			end
		end

	raise_schema_error (a_attribute, a_problem: STRING)
			-- Fail fast with a wiring-time diagnostic.
		do
			(create {EXCEPTIONS}).raise (generating_type.name_32.out + ": attribute %'" + a_attribute + "%' " + a_problem)
		end

end
