note
	description: "CORS filter for Todo-Backend demo server."
	date: "$Date$"
	revision: "$Revision$"

class
	TODO_CORS_FILTER

inherit
	WSF_FILTER

feature -- Basic operations

	execute (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Add CORS headers and handle CORS preflight.
		local
			l_header: HTTP_HEADER
			l_allow_headers: READABLE_STRING_8
		do
			create l_header.make
				-- Allow any origin
			l_header.put_access_control_allow_all_origin

				-- Allow headers used by the client.
				-- Prefer what the browser requested during preflight, if available.
			if attached req.http_access_control_request_headers as l_requested and then not l_requested.is_empty then
				l_allow_headers := l_requested
			else
				l_allow_headers := "Content-Type, Accept, Origin, X-Requested-With"
			end
			l_header.put_access_control_allow_headers (l_allow_headers)

				-- Allow HTTP methods required by the Todo-Backend spec
			l_header.put_header_key_value ({HTTP_HEADER_NAMES}.header_access_control_allow_methods,
				"GET, POST, PUT, DELETE, PATCH, OPTIONS")

			if req.is_request_method ({HTTP_REQUEST_METHODS}.method_options) then
					-- CORS preflight: respond directly with headers and no body.
				l_header.put_content_type ({HTTP_MIME_TYPES}.text_plain)
				l_header.put_content_length (0)
				res.set_status_code ({HTTP_STATUS_CODE}.ok)
				res.put_header_lines (l_header)
			else
					-- Normal request: add CORS headers then continue filter chain.
				res.put_header_lines (l_header)
				execute_next (req, res)
			end
		end

end
