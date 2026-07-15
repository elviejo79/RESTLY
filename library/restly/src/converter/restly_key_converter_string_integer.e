note
	description: "Key bijection: STRING on the representation side, INTEGER in the store."

class
	RESTLY_KEY_CONVERTER_STRING_INTEGER

inherit
	RESTLY_KEY_CONVERTER [STRING, INTEGER]

feature -- Conversion

	to_store (a_representation: STRING): INTEGER
		do
			Result := a_representation.to_integer
		end

	to_representation (a_store: INTEGER): STRING
		do
			Result := a_store.out
		end

end
