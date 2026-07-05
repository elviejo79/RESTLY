note
	description: "Identity converter for JSON_OBJECT (test helper)."

class
	JSON_IDENTITY_CONVERTER

inherit
	RESTLY_CONVERTER [JSON_OBJECT, JSON_OBJECT]

feature -- Conversion

	to_store (a_representation: JSON_OBJECT): JSON_OBJECT
		do
			Result := a_representation
		end

	to_representation (a_store: JSON_OBJECT): JSON_OBJECT
		do
			Result := a_store
		end

end
