note
	description: "Converts STRING keys to INTEGER and back for testing."

class
	SAMPLE_KEY_CONVERTER

inherit
	RESTLY_KEY_CONVERTER [STRING, INTEGER]

feature -- Conversion

	to_store (a_representation: STRING): INTEGER
			-- "42" -> 42.
		do
			Result := a_representation.to_integer
		end

	to_representation (a_store: INTEGER): STRING
			-- 42 -> "42".
		do
			Result := a_store.out
		end

end
