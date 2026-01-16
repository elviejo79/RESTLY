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

	backend: PICO_VERBS[R, JSON_OBJECT]
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
			elseif req.request_method.is_case_insensitive_equal ("PATCH") and has_id then
				-- PATCH /resource/{id} - partial update
				Result := safely (req, agent do_patch)
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

feature {NONE} -- Helpers

	has_id_parameter (req: WSF_REQUEST): BOOLEAN
			-- Does request have a non-empty id path parameter?
		do
			if attached req.path_parameter ("id") as l_param and then
			   not l_param.string_representation.is_empty then
				Result := True
			end
		end

	extract_id (req: WSF_REQUEST): PATH
			-- Extract id from path parameter
		require
			has_id_parameter (req)
		do
			check attached req.path_parameter ("id") as l_param then
				create Result.make_from_string (l_param.string_representation.to_string_8)
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
			max_body_length: INTEGER
		do
			max_body_length := 1024
			create Result.make (256)

			if not attached last_exception as l_exception then
				Result.append ("No exception available")
			else
				-- Exception tag
				if attached l_exception.tag as tag then
					Result.append (tag.to_string_8)
				else
					Result.append ("Unknown")
				end
				Result.append (": ")

				-- Exception description
				if attached l_exception.description as desc then
					Result.append (desc.to_string_8)
				else
					Result.append ("No description available")
				end

				-- Request context
				Result.append ("%NRequest: ")
				Result.append (req.request_method)
				Result.append (" ")
				Result.append (req.request_uri)

				-- Request body if available
				if req.raw_input_data_recorded and then attached req.raw_input_data as raw then
					Result.append ("%NBody: ")
					if raw.count > max_body_length then
						Result.append (raw.substring (1, max_body_length))
						Result.append ("... (truncated)")
					else
						Result.append (raw)
					end
				end
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
