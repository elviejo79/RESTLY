note
	description: "Identity converter for JSON_OBJECT (todobackend stores JSON directly)."

class
	TODOBACKEND_VALUE_CONVERTER

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
