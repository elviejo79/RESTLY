note
	description: "[
		Generic REST resource handler for PICO_REQUEST_METHODS_UNCONSTRAINED backends.
		Provides complete CRUD HTTP routing with exception handling.
		Subclasses only need to provide backend and base_url.
	]"

deferred class
	PICO_RESOURCE_HANDLER[R -> attached ANY]

inherit
	WSF_URI_TEMPLATE_RESPONSE_HANDLER

	EXCEPTION_MANAGER
		export
			{NONE} all
		end

feature {NONE} -- Backend (deferred)

	backend: PICO_VERBS[R]
			-- The storage backend for resources
		deferred
		end

	base_url: STRING
			-- Base URL for building resource URLs
		deferred
		end

feature -- Access

	response (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Handle REST requests
		local
			has_id: BOOLEAN
		do
			has_id := has_id_parameter (req)

			if req.is_get_request_method and has_id then
				-- GET /resource/{id}
				Result := safely (req, agent do_get)
			elseif req.is_get_request_method and not has_id then
				-- GET /resource - return all
				Result := safely (req, agent do_get_all)
			elseif req.is_post_request_method and not has_id then
				-- POST /resource - create new
				Result := safely (req, agent do_post)
			elseif req.request_method.is_case_insensitive_equal ("PUT") and has_id then
				-- PUT /resource/{id} - replace entire resource
				Result := safely (req, agent do_put)
			elseif req.request_method.is_case_insensitive_equal ("PATCH") and has_id then
				-- PATCH /resource/{id} - partial update
				Result := safely (req, agent do_patch)
			elseif req.request_method.is_case_insensitive_equal ("HEAD") and has_id then
				-- HEAD /resource/{id} - check if resource exists
				Result := safely (req, agent do_head)
			elseif req.is_delete_request_method and has_id then
				-- DELETE /resource/{id}
				Result := safely (req, agent do_delete)
			elseif req.is_delete_request_method and not has_id then
				-- DELETE /resource - delete all
				Result := safely (req, agent do_delete_all)
			else
				Result := {WSF_JSON_RESPONSE}.method_not_allowed
			end
		end

feature {NONE} -- HTTP Verbs (deferred)

	do_get (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /resource/{id} - retrieve single resource
		deferred
		end

	do_get_all (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /resource - retrieve all resources
		deferred
		end

	do_post (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- POST /resource - create new resource
		deferred
		end

	do_put (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- PUT /resource/{id} - replace entire resource
		deferred
		end

	do_patch (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- PATCH /resource/{id} - partial update
		deferred
		end

	do_delete (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- DELETE /resource/{id}
		deferred
		end

	do_delete_all (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- DELETE /resource - delete all
		deferred
		end

	do_head (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- HTTP HEAD on a resource: returns 200 if present, 404 otherwise
		deferred
		end

feature {NONE} -- Constants

	Max_body_length: INTEGER = 1024
			-- Maximum length of request body to include in exception details

	Initial_buffer_size: INTEGER = 512
			-- Initial size for exception detail string buffer

feature {NONE} -- Helpers

	extract_id_string (req: WSF_REQUEST): detachable STRING_8
			-- Extract id string from path parameter, or Void if not present
		do
			if attached req.path_parameter ("id") as l_param then
				if attached {WSF_STRING} l_param as l_str then
					Result := l_str.value.to_string_8
				elseif attached {WSF_TABLE} l_param as l_table and then l_table.count > 0 then
					-- URI template parameter returns a WSF_TABLE, get first value
					across l_table as ic loop
						Result := ic.string_representation.to_string_8
					end
				else
					Result := l_param.string_representation.to_string_8
				end
			end
		end

	has_id_parameter (req: WSF_REQUEST): BOOLEAN
			-- Does request have a non-empty id path parameter?
		do
			Result := attached extract_id_string (req) as id_value and then not id_value.is_empty
		end

	extract_id (req: WSF_REQUEST): PATH
			-- Extract id from path parameter
		require
			has_id_parameter (req)
		do
			check attached extract_id_string (req) as id_string then
				create Result.make_from_string (id_string)
			end
		end

	extract_json (req: WSF_REQUEST): JSON_OBJECT
			-- Parse JSON object from request body and convert to R
		require
			request_cant_be_empty: req.content_length_value > 0
		local
			json_parser: JSON_PARSER
			input_data: STRING
		do
			create input_data.make_empty
			req.read_input_data_into (input_data)
			create json_parser.make_with_string (input_data)
			json_parser.parse_content
			check attached {JSON_OBJECT} json_parser.parsed_json_value as parsed_obj then
				Result := parsed_obj
			end
		end

	json_ok (obj: JSON_VALUE): WSF_JSON_RESPONSE
			-- Create OK response with JSON body
		do
			Result := {WSF_JSON_RESPONSE}.ok.with_body (obj.representation)
		end

	safely (req: WSF_REQUEST; action: FUNCTION [TUPLE [WSF_REQUEST], WSF_JSON_RESPONSE]): WSF_JSON_RESPONSE
			-- Execute `action` with `req`, converting exceptions into JSON responses.
		do
			req.set_raw_input_data_recorded (True)
			if not attached Result then
				Result := action.item ([req])
			end
		rescue
			Result := convert_exception_to_response (req)
			retry
		end

	build_exception_detail (req: WSF_REQUEST): STRING
			-- Build a detailed message for the last exception, including request context.
		local
			tag_str, desc_str, body_str, trace_str: STRING
		do
			if not attached last_exception as l_exception then
				Result := "No exception available"
			else
				-- Exception tag
				if attached l_exception.tag as tag then
					tag_str := tag.to_string_8
				else
					tag_str := "(none)"
				end

				-- Exception description
				if attached l_exception.description as desc then
					desc_str := desc.to_string_8
				else
					desc_str := "(no description)"
				end

				-- Request body
				body_str := ""
				if req.raw_input_data_recorded and then attached req.raw_input_data as raw then
					if raw.count > Max_body_length then
						body_str := "Body: " + raw.substring (1, Max_body_length) + "... (truncated)%N"
					else
						body_str := "Body: " + raw + "%N"
					end
				end

				-- Stack trace
				trace_str := ""
				if attached l_exception.trace as trace then
					trace_str := "Stack trace:%N" + trace.to_string_8
				end

				-- Combine all parts
				Result := "Exception: " + l_exception.generating_type.name_32.to_string_8 + "%N" +
				          "Code: " + l_exception.code.out + "%N" +
				          "Tag: " + tag_str + "%N" +
				          "Message: " + desc_str + "%N" +
				          "Request: " + req.request_method + " " + req.request_uri + "%N" +
				          body_str +
				          trace_str
			end
		end

	convert_exception_to_response (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- Handle exceptions based on exception type, including exception details
		local
			exception_detail: STRING
		do
			exception_detail := build_exception_detail (req)

			if not attached last_exception as l_exception then
				Result := {WSF_JSON_RESPONSE}.internal_server_error.with_detail (exception_detail)
			elseif attached {PRECONDITION_VIOLATION} l_exception then
				if attached l_exception.tag as tag and then
				   tag.has_substring ("requested_a_known_key_or_throw_404_not_found") then
					Result := {WSF_JSON_RESPONSE}.not_found.with_detail (exception_detail)
				else
					Result := {WSF_JSON_RESPONSE}.precondition_failed.with_detail (exception_detail)
				end
			elseif attached {POSTCONDITION_VIOLATION} l_exception then
				Result := {WSF_JSON_RESPONSE}.internal_server_error.with_detail (exception_detail)
			else
				Result := {WSF_JSON_RESPONSE}.internal_server_error.with_detail (exception_detail)
			end
		end

end
