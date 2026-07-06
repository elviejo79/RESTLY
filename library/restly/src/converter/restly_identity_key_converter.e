note
	description: "Key converter that returns its argument unchanged."

class
	RESTLY_IDENTITY_KEY_CONVERTER [K]

inherit
	RESTLY_KEY_CONVERTER [K, K]

feature -- Conversion

	to_store (a_representation: K): K
		do
			Result := a_representation
		end

	to_representation (a_store: K): K
		do
			Result := a_store
		end

end
