note
	description: "Adds todobackend defaults (completed: false) on retrieval."

class
	TODOBACKEND_CONVERTER

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
			if not Result.has_key ("completed") then
				Result.put_boolean (False, "completed")
			end
		end

end
