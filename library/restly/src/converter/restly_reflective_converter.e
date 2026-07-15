note
	description: "[
		Converter between a representation R and a store S driven by
		reflection. Attributes whose name and type match a
		representation field flow automatically in both directions;
		only mismatches (renames, type changes, store-only attributes)
		are declared, once, in `correct_mismatches` —
		{MISMATCH_CORRECTOR}'s idea applied to representation/store
		conversion.
		Format-independent: the typed field access (`has_integer`,
		`integer_item`, `put_boolean`, ...) is deferred; one
		effecting class per format
		(e.g. {RESTLY_JSON_REFLECTIVE_CONVERTER}) declares
		`default_create` as its creation procedure: a converter is
		fully determined by its class.
		Natural types: INTEGER, BOOLEAN, STRING. Reference attributes
		must be initialized by S's `default_create` (the schema check
		reads them to learn their type).
		Creation fails fast — at wiring time, not mid-request — on any
		attribute neither matched nor declared.
	]"

deferred class
	RESTLY_REFLECTIVE_CONVERTER [R, S -> ANY create default_create end]

inherit
	RESTLY_CONVERTER [R, S]
		redefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- Collect mismatch declarations, then verify every
			-- attribute of S is matched, renamed, converted or skipped.
		do
			create renamings.make (0)
			create skips.make (0)
			create from_converters.make (0)
			create to_converters.make (0)
			correct_mismatches
			check_schema
		ensure then
			error_500_all_attributes_accounted: True
					-- TODO(owner): contract
					-- suggested: every attribute of S is matched,
					-- renamed, converted, or skipped — no silent gaps
		end

feature -- Conversion

	to_store (a_representation: R): S
			-- <Precursor>
			-- Fresh default-created store; absent representation fields
			-- keep the `default_create` defaults.
		local
			l_fields: REFLECTED_REFERENCE_OBJECT
			i: INTEGER
			l_name: STRING
		do
			create Result
			create l_fields.make (Result)
			from
				i := 1
			until
				i > l_fields.field_count
			loop
				l_name := l_fields.field_name (i)
				if skips.has (l_name) then
						-- Store-only attribute: keep the `default_create` default.
				elseif attached from_converters.item (l_name) as l_convert then
					l_convert (l_fields, i, a_representation, representation_key (l_name))
				else
					inspect l_fields.field_type (i)
					when {REFLECTOR_CONSTANTS}.integer_32_type then
						if has_integer (a_representation, representation_key (l_name)) then
							l_fields.set_integer_32_field (i, integer_item (a_representation, representation_key (l_name)))
						end
					when {REFLECTOR_CONSTANTS}.boolean_type then
						if has_boolean (a_representation, representation_key (l_name)) then
							l_fields.set_boolean_field (i, boolean_item (a_representation, representation_key (l_name)))
						end
					else
						if has_string (a_representation, representation_key (l_name)) then
							l_fields.set_reference_field (i, string_item (a_representation, representation_key (l_name)))
						end
					end
				end
				i := i + 1
			end
		end

	to_representation (a_store: S): R
			-- <Precursor>
			-- One representation field per non-skipped attribute of `a_store`.
		local
			l_fields: REFLECTED_REFERENCE_OBJECT
			i: INTEGER
			l_name: STRING
		do
			create l_fields.make (a_store)
			Result := new_representation (l_fields.field_count)
			from
				i := 1
			until
				i > l_fields.field_count
			loop
				l_name := l_fields.field_name (i)
				if skips.has (l_name) then
						-- Store-only attribute: never travels.
				elseif attached to_converters.item (l_name) as l_convert then
					l_convert (l_fields, i, Result, representation_key (l_name))
				else
					inspect l_fields.field_type (i)
					when {REFLECTOR_CONSTANTS}.integer_32_type then
						put_integer (l_fields.integer_32_field (i), Result, representation_key (l_name))
					when {REFLECTOR_CONSTANTS}.boolean_type then
						put_boolean (l_fields.boolean_field (i), Result, representation_key (l_name))
					else
						if attached {READABLE_STRING_GENERAL} l_fields.field (i) as l_string then
							put_string (l_string, Result, representation_key (l_name))
						end
					end
				end
				i := i + 1
			end
		end

feature -- Access

	has_integer (a_representation: R; a_key: READABLE_STRING_GENERAL): BOOLEAN
			-- Does `a_representation' carry an integer field `a_key'?
		deferred
		end

	integer_item (a_representation: R; a_key: READABLE_STRING_GENERAL): INTEGER
			-- Integer field `a_key' of `a_representation'.
		require
			error_500_has_field: True
					-- TODO(owner): contract
					-- suggested: has_integer (a_representation, a_key)
		deferred
		end

	has_boolean (a_representation: R; a_key: READABLE_STRING_GENERAL): BOOLEAN
			-- Does `a_representation' carry a boolean field `a_key'?
		deferred
		end

	boolean_item (a_representation: R; a_key: READABLE_STRING_GENERAL): BOOLEAN
			-- Boolean field `a_key' of `a_representation'.
		require
			error_500_has_field: True
					-- TODO(owner): contract
					-- suggested: has_boolean (a_representation, a_key)
		deferred
		end

	has_string (a_representation: R; a_key: READABLE_STRING_GENERAL): BOOLEAN
			-- Does `a_representation' carry a string field `a_key'?
		deferred
		end

	string_item (a_representation: R; a_key: READABLE_STRING_GENERAL): STRING
			-- String field `a_key' of `a_representation'.
		require
			error_500_has_field: True
					-- TODO(owner): contract
					-- suggested: has_string (a_representation, a_key)
		deferred
		end

feature -- Element Change

	put_integer (a_value: INTEGER; a_representation: R; a_key: READABLE_STRING_GENERAL)
			-- Set field `a_key' of `a_representation' to `a_value'.
		deferred
		end

	put_boolean (a_value: BOOLEAN; a_representation: R; a_key: READABLE_STRING_GENERAL)
			-- Set field `a_key' of `a_representation' to `a_value'.
		deferred
		end

	put_string (a_value: READABLE_STRING_GENERAL; a_representation: R; a_key: READABLE_STRING_GENERAL)
			-- Set field `a_key' of `a_representation' to `a_value'.
		deferred
		end

feature -- Factory

	new_representation (a_capacity: INTEGER): R
			-- Fresh empty representation sized for `a_capacity' fields.
		deferred
		end

feature {NONE} -- Mismatch declarations

	correct_mismatches
			-- Declare the deviations between S's schema and the
			-- representation schema. Default: none — every attribute
			-- matches its representation field by name and type
			-- ("attribute not changed").
		do
		end

	rename_field (a_attribute, a_representation_key: STRING)
			-- "Attribute renamed": `a_attribute` travels in the
			-- representation as `a_representation_key`.
		require
			error_500_attribute_exists: True
					-- TODO(owner): contract
					-- suggested: S has an attribute named `a_attribute`
		do
			renamings.force (a_representation_key, a_attribute)
		end

	skip_field (a_attribute: STRING)
			-- "Attribute removed" (from the representation's view):
			-- `a_attribute` never travels in the representation.
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
			-- store, boolean in the representation; both directions
			-- declared together.
			-- ponytail: only sugar pair needed today; add a sibling
			-- feature per (representation type, attribute type) pair
			-- when a resource needs one.
		require
			error_500_attribute_exists: True
					-- TODO(owner): contract
		do
			from_converters.force (
				agent (a_fields: REFLECTED_REFERENCE_OBJECT; i: INTEGER; a_representation: R; a_key: READABLE_STRING_GENERAL; a_convert: FUNCTION [BOOLEAN, INTEGER])
					do
						if has_boolean (a_representation, a_key) then
							a_fields.set_integer_32_field (i, a_convert (boolean_item (a_representation, a_key)))
						end
					end (?, ?, ?, ?, a_to_store),
				a_attribute)
			to_converters.force (
				agent (a_fields: REFLECTED_REFERENCE_OBJECT; i: INTEGER; a_representation: R; a_key: READABLE_STRING_GENERAL; a_convert: FUNCTION [INTEGER, BOOLEAN])
					do
						put_boolean (a_convert (a_fields.integer_32_field (i)), a_representation, a_key)
					end (?, ?, ?, ?, a_to_representation),
				a_attribute)
		end

feature {NONE} -- Implementation

	renamings: STRING_TABLE [STRING]
			-- Attribute name -> representation key.

	skips: STRING_TABLE [BOOLEAN]
			-- Attributes that never travel in the representation.

	from_converters: STRING_TABLE [PROCEDURE [REFLECTED_REFERENCE_OBJECT, INTEGER, R, READABLE_STRING_GENERAL]]
			-- Attribute name -> representation-to-field direction of a
			-- type change; reads the representation through the format.

	to_converters: STRING_TABLE [PROCEDURE [REFLECTED_REFERENCE_OBJECT, INTEGER, R, READABLE_STRING_GENERAL]]
			-- Attribute name -> field-to-representation direction;
			-- always declared together with `from_converters` by the
			-- convert_* sugar.

	representation_key (a_attribute: READABLE_STRING_GENERAL): STRING
			-- Representation field name for `a_attribute`: its declared
			-- rename, or the attribute name itself.
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
			create l_fields.make (create {S})
			create l_known.make (l_fields.field_count)
			from
				i := 1
			until
				i > l_fields.field_count
			loop
				l_name := l_fields.field_name (i)
				l_known.force (True, l_name)
				if not (skips.has (l_name) or from_converters.has (l_name)) then
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
			check_declared_exist (from_converters.current_keys, l_known)
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
