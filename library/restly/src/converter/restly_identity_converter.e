note
	description: "Converter that returns its argument unchanged."

class
	RESTLY_IDENTITY_CONVERTER [V]

inherit
	RESTLY_CONVERTER [V, V]

feature -- Conversion

	to_store (a_representation: V): V
		do
			Result := a_representation
		end

	to_representation (a_store: V): V
		do
			Result := a_store
		end

end
