note
    description: "[
        A JSON response message with proper HTTP status messages.
        Automatically uses HTTP_STATUS_CODE_MESSAGES for status descriptions.
        Sets Content-Type to application/json with UTF-8 charset.
    ]"
    date: "$Date$"
    revision: "$Revision$"

class
    WSF_JSON_RESPONSE

inherit
    WSF_PAGE_RESPONSE
        redefine
            make,
            send_to
        end

create
    make,
    make_with_body,
    make_with_status

feature
code_to: HTTP_STATUS_CODE_MESSAGES
      once
        create Result
      end
feature {NONE} -- Initialization

    make
        do
            Precursor
            header.put_content_type_with_charset ("application/json", "utf-8")
        end

    make_with_status (a_status: INTEGER)
            -- Initialize with specific status code and default message
        require
            valid_status: a_status > 0
        do
            make
            set_status_code (a_status)
            set_default_json_body
        ensure
            status_set: status_code = a_status
        end

feature -- Access

    default_json_for_status: STRING
            -- Generate default JSON based on current status code using HTTP_STATUS_CODE_MESSAGES
        local
            msg: STRING
            key: STRING
        do
            if attached code_to.http_status_code_message (status_code) as status_msg then
                msg := status_msg
            else
                msg := "Status " + status_code.out
            end

            if status_code >= {HTTP_STATUS_CODE}.bad_request then
                key := "error"
            else
                key := "message"
            end

            Result := "{%"" + key + "%":%"" + msg + "%",%"status%":" + status_code.out + "}"
        end

feature -- Element change

    set_default_json_body
            -- Set body to default JSON based on status code
        do
            set_body (default_json_for_status)
        end

feature -- Factory: Client errors (4xx)

    not_found: WSF_JSON_RESPONSE
            -- Create new 404 Not Found response
        do
            create Result.make_with_status ({HTTP_STATUS_CODE}.not_found)
        ensure
            instance_free: class
        end

    bad_request: WSF_JSON_RESPONSE
            -- Create new 400 Bad Request response
        do
            create Result.make_with_status ({HTTP_STATUS_CODE}.bad_request)
        ensure
            instance_free: class
        end

    conflict: WSF_JSON_RESPONSE
            -- Create new 409 Conflict response
        do
            create Result.make_with_status ({HTTP_STATUS_CODE}.conflict)
        ensure
            instance_free: class
        end

    precondition_failed: WSF_JSON_RESPONSE
            -- Create new 412 Precondition Failed response
        do
            create Result.make_with_status ({HTTP_STATUS_CODE}.precondition_failed)
        ensure
            instance_free: class
        end

    method_not_allowed: WSF_JSON_RESPONSE
            -- Create new 405 Method Not Allowed response
        do
            create Result.make_with_status ({HTTP_STATUS_CODE}.method_not_allowed)
        ensure
            instance_free: class
        end

    unauthorized: WSF_JSON_RESPONSE
            -- Create new 401 Unauthorized response
        do
            create Result.make_with_status ({HTTP_STATUS_CODE}.unauthorized)
        ensure
            instance_free: class
        end

    forbidden: WSF_JSON_RESPONSE
            -- Create new 403 Forbidden response
        do
            create Result.make_with_status ({HTTP_STATUS_CODE}.forbidden)
        ensure
            instance_free: class
        end

feature -- Factory: Success responses (2xx)

    ok: WSF_JSON_RESPONSE
            -- Create new 200 OK response
        do
            create Result.make_with_status ({HTTP_STATUS_CODE}.ok)
        ensure
            instance_free: class
        end

    created: WSF_JSON_RESPONSE
            -- Create new 201 Created response
        do
            create Result.make_with_status ({HTTP_STATUS_CODE}.created)
        ensure
            instance_free: class
        end

    no_content: WSF_JSON_RESPONSE
            -- Create new 204 No Content response
            -- Note: 204 MUST NOT include a message body per HTTP spec (RFC 7231)
        do
            create Result.make
            Result.set_status_code ({HTTP_STATUS_CODE}.no_content)
        ensure
            instance_free: class
        end

feature -- Factory: Server errors (5xx)

    internal_server_error: WSF_JSON_RESPONSE
            -- Create new 500 Internal Server Error response
        do
            create Result.make_with_status ({HTTP_STATUS_CODE}.internal_server_error)
        ensure
            instance_free: class
        end

feature -- Fluent setters (chainable)

    with_body (a_body: STRING): like Current
            -- Set custom JSON body (chainable)
            -- Replaces default status message
        do
            set_body (a_body)
            Result := Current
        end

    with_detail (a_detail: STRING): like Current
            -- Add detail field to default JSON (chainable)
            -- Enhances the default error/message with additional info
        local
            msg: STRING
            key: STRING
        do
            -- Determine message key based on status code
            if status_code >= {HTTP_STATUS_CODE}.bad_request then
                key := "error"
            else
                key := "message"
            end

            if attached code_to.http_status_code_message (status_code) as status_msg then
                msg := status_msg
            else
                msg := "Status " + status_code.out
            end

            -- Build JSON using string concatenation
            set_body ("{%"" + key + "%":%"" + msg + "%",%"details%":%"" + a_detail + "%",%"status%":" + status_code.out + "}")
            Result := Current
        end

    with_location (a_uri: STRING): like Current
            -- Set Location header (chainable)
        require
            uri_not_empty: not a_uri.is_empty
        do
            header.put_location (a_uri)
            Result := Current
        end

    with_header (a_name, a_value: STRING): like Current
            -- Add custom header (chainable)
        require
            name_not_empty: not a_name.is_empty
        do
            header.put_header (a_name + ": " + a_value)
            Result := Current
        end

    with_json_object (a_json: JSON_OBJECT): like Current
            -- Set body from JSON_OBJECT (chainable)
        do
            set_body (a_json.representation)
            Result := Current
        end

feature {WSF_RESPONSE} -- Output

    send_to (res: WSF_RESPONSE)
            -- Send JSON response to client
        local
            h: like header
        do
            h := header
            res.set_status_code (status_code)

            -- Ensure Content-Type is set to application/json with charset
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

note
    copyright: "2024-2025"
    license: "MIT"
end
