note
	description: "STRING to INTEGER key converter."

class
	RESTLY_INT_KEY_CONVERTER

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
