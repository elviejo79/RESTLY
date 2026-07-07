note
	description: "[
		JSON response message with proper HTTP status codes.
		Inherits WSF_PAGE_RESPONSE; sets Content-Type to
		application/json; charset=utf-8 on every creation path.
	]"

class
	WSF_JSON_RESPONSE

inherit
	WSF_PAGE_RESPONSE
		redefine
			make,
			make_with_body,
			send_to
		end

create
	make,
	make_with_body,
	make_with_status

feature {NONE} -- Initialization

	make
		do
			Precursor
			header.put_content_type_with_charset ("application/json", "utf-8")
		end

	make_with_body (a_body: STRING_8)
			-- <Precursor>
		do
			Precursor (a_body)
			header.put_content_type_with_charset ("application/json", "utf-8")
		end

	make_with_status (a_status: INTEGER)
			-- Initialize with `a_status' and a default JSON body.
		require
			valid_status: a_status > 0
		do
			make
			set_status_code (a_status)
			if a_status /= {HTTP_STATUS_CODE}.no_content then
				set_default_json_body
			end
		ensure
			status_set: status_code = a_status
		end

feature -- Access

	code_to: HTTP_STATUS_CODE_MESSAGES
		once
			create Result
		end

	json_body: detachable JSON_OBJECT
			-- Current `body' parsed as JSON, if valid.
		local
			l_parser: JSON_PARSER
		do
			if attached body as l_body then
				create l_parser.make_with_string (l_body)
				l_parser.parse_content
				if l_parser.is_valid then
					Result := l_parser.parsed_json_object
				end
			end
		end

	json_body_object: JSON_OBJECT
			-- Base JSON object for current `status_code'.
		local
			l_key_name: JSON_STRING
			l_msg: STRING
		do
			if attached code_to.http_status_code_message (status_code) as l_status_msg then
				l_msg := l_status_msg
			else
				l_msg := "Status " + status_code.out
			end
			if status_code >= {HTTP_STATUS_CODE}.bad_request then
				create l_key_name.make_from_string ("error")
			else
				create l_key_name.make_from_string ("message")
			end
			create Result.make_with_capacity (3)
			Result.put_string (l_msg, l_key_name)
			Result.put_integer (status_code, create {JSON_STRING}.make_from_string ("status"))
		end

	default_json_for_status: STRING
			-- Valid JSON body for current `status_code'.
		do
			Result := json_body_object.representation
		end

feature -- Element change

	set_default_json_body
			-- Set `body' to `default_json_for_status'.
		do
			set_body (default_json_for_status)
		end

feature -- Factory: Client errors (4xx)

	not_found: WSF_JSON_RESPONSE
		do
			create Result.make_with_status ({HTTP_STATUS_CODE}.not_found)
		ensure
			instance_free: class
		end

	bad_request: WSF_JSON_RESPONSE
		do
			create Result.make_with_status ({HTTP_STATUS_CODE}.bad_request)
		ensure
			instance_free: class
		end

	conflict: WSF_JSON_RESPONSE
		do
			create Result.make_with_status ({HTTP_STATUS_CODE}.conflict)
		ensure
			instance_free: class
		end

	precondition_failed: WSF_JSON_RESPONSE
		do
			create Result.make_with_status ({HTTP_STATUS_CODE}.precondition_failed)
		ensure
			instance_free: class
		end

	method_not_allowed: WSF_JSON_RESPONSE
		do
			create Result.make_with_status ({HTTP_STATUS_CODE}.method_not_allowed)
		ensure
			instance_free: class
		end

	unauthorized: WSF_JSON_RESPONSE
		do
			create Result.make_with_status ({HTTP_STATUS_CODE}.unauthorized)
		ensure
			instance_free: class
		end

	forbidden: WSF_JSON_RESPONSE
		do
			create Result.make_with_status ({HTTP_STATUS_CODE}.forbidden)
		ensure
			instance_free: class
		end

feature -- Factory: Success responses (2xx)

	ok: WSF_JSON_RESPONSE
		do
			create Result.make_with_status ({HTTP_STATUS_CODE}.ok)
		ensure
			instance_free: class
		end

	created: WSF_JSON_RESPONSE
		do
			create Result.make_with_status ({HTTP_STATUS_CODE}.created)
		ensure
			instance_free: class
		end

	no_content: WSF_JSON_RESPONSE
		do
			create Result.make_with_status ({HTTP_STATUS_CODE}.no_content)
		ensure
			instance_free: class
		end

feature -- Factory: Server errors (5xx)

	internal_server_error: WSF_JSON_RESPONSE
		do
			create Result.make_with_status ({HTTP_STATUS_CODE}.internal_server_error)
		ensure
			instance_free: class
		end

feature -- Fluent setters

	with_body (a_body: STRING): like Current
			-- Set custom JSON body.
		do
			set_body (a_body)
			Result := Current
		end

	with_detail (a_detail: READABLE_STRING_GENERAL): like Current
			-- Add detail field to default JSON body.
		local
			l_obj: JSON_OBJECT
		do
			l_obj := json_body_object
			l_obj.put_string (a_detail, create {JSON_STRING}.make_from_string ("detail"))
			set_body (l_obj.representation)
			Result := Current
		end

	with_location (a_uri: STRING): like Current
			-- Set Location header.
		do
			header.put_location (a_uri)
			Result := Current
		end

	with_header (a_name, a_value: STRING): like Current
			-- Add custom header.
		do
			header.put_header (a_name + ": " + a_value)
			Result := Current
		end

	with_json_object (a_json: JSON_OBJECT): like Current
			-- Set body from `a_json'.
		do
			set_body (a_json.representation)
			Result := Current
		end

feature {WSF_RESPONSE} -- Output

	send_to (res: WSF_RESPONSE)
		local
			h: like header
		do
			h := header
			res.set_status_code (status_code)
			if not h.has_content_type then
				h.put_content_type_with_charset ("application/json", "utf-8")
			end
			if attached body as b then
				if not h.has_content_length then
					h.put_content_length (b.count)
				end
				res.put_header_lines (h)
				res.put_string (b)
			else
				res.put_header_lines (h)
			end
		end

end
