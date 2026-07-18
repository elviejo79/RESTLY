note
	description: "[
		Adds todobackend defaults (completed: false) and the element
		url (from the stamped "id") on retrieval.
	]"

class
	TODOBACKEND_CONVERTER

inherit
	RESTLY_CONVERTER [JSON_OBJECT, JSON_OBJECT]

create
	make

feature {NONE} -- Initialization

	make (a_base_url: STRING)
			-- Converter minting element urls under `a_base_url`.
		do
			base_url := a_base_url
		end

feature -- Access

	base_url: STRING
			-- Collection url; element url = `base_url` + "/" + id.

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
			if attached {JSON_STRING} Result.item ("id") as l_id then
				Result.replace_with_string (base_url + "/" + l_id.unescaped_string_8, "url")
			end
		end

end
