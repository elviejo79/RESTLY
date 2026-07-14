note
	description: "[
		JSON effecting of the reflective converter: typed field access
		on JSON_OBJECT. Directly creatable for stores whose attributes
		all match their JSON fields; a store with mismatches gets a
		named descendant redefining `correct_mismatches`
		(e.g. TODOBACKEND_JSON_CONVERTER).
	]"

class
	RESTLY_JSON_REFLECTIVE_CONVERTER [S -> ANY]

inherit
	RESTLY_REFLECTIVE_CONVERTER [JSON_OBJECT, S]

create
	make

feature -- Access

	has_integer (a_representation: JSON_OBJECT; a_key: READABLE_STRING_GENERAL): BOOLEAN
			-- <Precursor>
		do
			Result := attached {JSON_NUMBER} a_representation.item (a_key)
		end

	integer_item (a_representation: JSON_OBJECT; a_key: READABLE_STRING_GENERAL): INTEGER
			-- <Precursor>
		do
			if attached {JSON_NUMBER} a_representation.item (a_key) as l_number then
				Result := l_number.integer_64_item.to_integer_32
			end
		end

	has_boolean (a_representation: JSON_OBJECT; a_key: READABLE_STRING_GENERAL): BOOLEAN
			-- <Precursor>
		do
			Result := attached {JSON_BOOLEAN} a_representation.item (a_key)
		end

	boolean_item (a_representation: JSON_OBJECT; a_key: READABLE_STRING_GENERAL): BOOLEAN
			-- <Precursor>
		do
			if attached {JSON_BOOLEAN} a_representation.item (a_key) as l_boolean then
				Result := l_boolean.item
			end
		end

	has_string (a_representation: JSON_OBJECT; a_key: READABLE_STRING_GENERAL): BOOLEAN
			-- <Precursor>
		do
			Result := attached {JSON_STRING} a_representation.item (a_key)
		end

	string_item (a_representation: JSON_OBJECT; a_key: READABLE_STRING_GENERAL): STRING
			-- <Precursor>
		do
			if attached {JSON_STRING} a_representation.item (a_key) as l_string then
				Result := l_string.unescaped_string_8
			else
				create Result.make_empty
			end
		end

feature -- Element Change

	put_integer (a_value: INTEGER; a_representation: JSON_OBJECT; a_key: READABLE_STRING_GENERAL)
			-- <Precursor>
		do
			a_representation.put_integer (a_value, a_key)
		end

	put_boolean (a_value: BOOLEAN; a_representation: JSON_OBJECT; a_key: READABLE_STRING_GENERAL)
			-- <Precursor>
		do
			a_representation.put_boolean (a_value, a_key)
		end

	put_string (a_value: READABLE_STRING_GENERAL; a_representation: JSON_OBJECT; a_key: READABLE_STRING_GENERAL)
			-- <Precursor>
		do
			a_representation.put_string (a_value, a_key)
		end

feature -- Factory

	new_representation (a_capacity: INTEGER): JSON_OBJECT
			-- <Precursor>
		do
			create Result.make_with_capacity (a_capacity)
		end

end
