note
	description: "[
		Deferred base for RESTLY-EWF verb handlers.
		Provides rescue/retry contract-to-HTTP mapping,
		tag parsing, JSON body parsing, CORS headers,
		and url patching.
	]"

deferred class
	RESTLY_EWF_HANDLER

inherit
	WSF_URI_TEMPLATE_RESPONSE_HANDLER

	EXCEPTION_MANAGER
		export
			{NONE} all
		end

feature {NONE} -- Initialization

	make (a_storage: RESTLY_PROTOCOL [STRING, JSON_OBJECT])
			-- Initialize with `a_storage'.
		do
			storage := a_storage
		end

feature -- Access

	storage: RESTLY_PROTOCOL [STRING, JSON_OBJECT]
			-- Backing pipeline.

feature -- Dispatch

	response (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Verb dispatch with rescue/retry error mapping.
		do
			if attached Result then
				-- retry path: Result was set by handle_rescue
			elseif req.is_request_method ("OPTIONS") then
				Result := {WSF_JSON_RESPONSE}.no_content
			else
				Result := dispatch (req)
			end
			add_cors_headers (Result)
		rescue
			Result := handle_rescue
			retry
		end

feature {NONE} -- Dispatch

	dispatch (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Route the request to the appropriate verb handler.
		deferred
		end

feature {NONE} -- Exception to HTTP status

	handle_rescue: WSF_JSON_RESPONSE
			-- Map contract violations to HTTP responses.
		local
			l_status: INTEGER
			l_detail: STRING
		do
			if attached last_exception as l_exc then
				l_status := status_from_exception (l_exc)
				if attached l_exc.description as l_desc then
					l_detail := l_desc.to_string_8
				elseif attached l_exc.tag as l_tag then
					l_detail := l_tag.to_string_8
				else
					l_detail := "Internal error"
				end
				Result := create {WSF_JSON_RESPONSE}.make_with_status (l_status)
				Result := Result.with_detail (l_detail)
			else
				Result := {WSF_JSON_RESPONSE}.internal_server_error
			end
		end

	status_from_exception (a_exc: EXCEPTION): INTEGER
			-- Extract HTTP status from exception tag or type.
		do
			if attached a_exc.tag as l_tag then
				Result := status_from_tag (l_tag.to_string_8)
			end
			if Result = 0 then
				if attached {PRECONDITION_VIOLATION} a_exc then
					Result := {HTTP_STATUS_CODE}.precondition_failed
				else
					Result := {HTTP_STATUS_CODE}.internal_server_error
				end
			end
		end

	status_from_tag (a_tag: STRING): INTEGER
			-- Parse "error_NNN_description" to NNN. Returns 0 if no match.
		local
			l_start, l_end: INTEGER
			l_code: STRING
		do
			if a_tag.starts_with ("error_") and a_tag.count > 6 then
				l_start := 7
				l_end := a_tag.index_of ('_', l_start)
				if l_end > l_start then
					l_code := a_tag.substring (l_start, l_end - 1)
					if l_code.is_integer then
						Result := l_code.to_integer
					end
				end
			end
		end

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

	add_cors_headers (a_response: WSF_RESPONSE_MESSAGE)
			-- Add CORS and connection headers to any response.
		do
			if attached {WSF_PAGE_RESPONSE} a_response as l_page then
				l_page.header.put_header ("Access-Control-Allow-Origin: *")
				l_page.header.put_header ("Access-Control-Allow-Methods: GET, POST, PATCH, DELETE, OPTIONS")
				l_page.header.put_header ("Access-Control-Allow-Headers: Content-Type, Accept")
				l_page.header.put_header ("Connection: close")
			end
		end

end
