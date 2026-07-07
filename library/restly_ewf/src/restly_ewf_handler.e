note
	description: "[
		Deferred base for RESTLY-EWF verb providers.
		Holds the backing pipeline and shared JSON/url helpers.
		Verb features are mapped per route via {RESTLY_EWF_ACTION_HANDLER}.
	]"

deferred class
	RESTLY_EWF_HANDLER

feature {NONE} -- Initialization

	make (a_storage: RESTLY_PROTOCOL [STRING, JSON_OBJECT])
			-- Initialize with `a_storage'.
		do
			storage := a_storage
		end

feature -- Access

	storage: RESTLY_PROTOCOL [STRING, JSON_OBJECT]
			-- Backing pipeline.

feature {NONE} -- Helpers

	parse_json_body (req: WSF_REQUEST): JSON_OBJECT
			-- Parse JSON from request body.
		local
			l_input: STRING
			l_parser: JSON_PARSER
		do
			create l_input.make_empty
			req.read_input_data_into (l_input)
			create l_parser.make_with_string (l_input)
			l_parser.parse_content
			if l_parser.is_valid and then attached l_parser.parsed_json_object as l_obj then
				Result := l_obj
			else
				create Result.make_with_capacity (0)
			end
		end

	patch_url (a_obj: JSON_OBJECT; a_key: STRING; req: WSF_REQUEST)
			-- Add/replace "url" field with the absolute URL for this element.
		local
			l_url: STRING
		do
			l_url := req.absolute_script_url (element_uri (a_key, req))
			a_obj.replace_with_string (l_url, "url")
		end

	element_uri (a_key: STRING; req: WSF_REQUEST): STRING
			-- URI for an element with `a_key' based on the current request.
		deferred
		end

end
