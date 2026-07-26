note
	description: "[
		Maps contract blame to HTTP: rescue helpers that turn
		assertion violations (error_NNN_* tags) into JSON responses
		with the right status, plus the CORS/connection headers every
		RESTLY response carries.
		Shared by EWF_CONTRACT_GUARD (call/return path) and
		RESTLY_EWF_HANDLER (container-protocol path).
	]"

deferred class
	RESTLY_CONTRACT_TO_HTTP

inherit
	EXCEPTION_MANAGER
		export
			{NONE} all
		end

feature {NONE} -- Exception to HTTP status

	handle_rescue_for_queries: WSF_JSON_RESPONSE
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

	handle_rescue_for_command (res: WSF_JSON_RESPONSE)
			-- Turn `res` into the error response for the pending
			-- exception: the command form of `handle_rescue_for_queries`,
			-- mutating the caller's response instead of returning one.
		do
			res.copy (handle_rescue_for_queries)
		end

	status_from_exception (a_exc: EXCEPTION): INTEGER
			-- Extract HTTP status from exception tag or type.
		do
			if attached a_exc.tag as l_tag then
				Result := status_from_tag (l_tag.to_string_8)
			end
			if Result = 0 and then attached a_exc.description as l_desc then
					-- Propagated violations carry the assertion tag in
					-- `description` rather than `tag`.
				Result := status_from_tag (l_desc.to_string_8)
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
				if l_end = 0 then
						-- Bare "error_NNN" tag, no trailing description.
					l_end := a_tag.count + 1
				end
				if l_end > l_start then
					l_code := a_tag.substring (l_start, l_end - 1)
					if l_code.is_integer then
						Result := l_code.to_integer
					end
				end
			end
		end

feature {NONE} -- Helpers

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
