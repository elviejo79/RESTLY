note
	description: "Exposes HTTTPico Resources to the web. This is the complement of PICO_HTTP_CLIENT"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
   PICO_HTTP_SERVER[R -> JSON_VALUE, S -> PICO_ENTITY]

inherit
	WSF_URI_TEMPLATE_RESPONSE_HANDLER

	EXCEPTION_MANAGER
		export
			{NONE} all
		end

feature {NONE} -- Initialization

	make (a_storage: like storage)
		do
			storage := a_storage
		end

feature {NONE} -- Fields

	storage: PICO_MAPPER [R, S]

	id_parameter_name: STRING = "id"

feature -- Access

response (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
    local
        has_id: BOOLEAN
    do
        has_id := has_id_parameter (req)

        if req.is_get_request_method and has_id then
            -- GET /resource/{id}
            Result := safely (req, agent do_get)
        elseif req.is_get_request_method and not has_id then
            -- GET /resources it should return the whole collection
            Result := safely (req, agent do_get_all)
        elseif req.is_put_request_method and has_id then
            -- PUT /resource/id
            Result := safely (req, agent do_put)
        elseif req.request_method.is_case_insensitive_equal ("PATCH") and has_id then
            -- PATCH /resource/id
            Result := safely (req, agent do_patch)
        elseif req.is_delete_request_method and has_id then
            -- DELETE /resource/id
            Result := safely (req, agent do_delete)
        elseif req.is_post_request_method and not has_id then
            -- POST /resource
            Result := safely (req, agent do_post)
        elseif req.is_delete_request_method and not has_id then
            -- DELETE /resources - delete all
            Result := safely (req, agent do_delete_all)
        else
            -- Anything else
            Result := {WSF_JSON_RESPONSE}.method_not_allowed
        end
    end

feature -- verbs like PICO_REQUEST_VERBS but all of them return messages;

feature
	do_post (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- POST /resource - create new resource
		do
			storage.collection_extend (extract_json (req))
			check attached storage.last_inserted_key as last_id then
				Result := json_ok (storage.item (last_id))
			end
		end

	do_put (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- PUT /resource/{id} - replace entire resource
		local
			id_key: PATH_PICO
		do
			id_key := extract_id (req)
			storage.force (extract_json (req), id_key)
			Result := json_ok (storage.item (id_key))
		end

    do_delete (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- DELETE resource
		do
         storage.remove (extract_id (req))
				-- 204 No Content: {"message": "No Content", "status": 204}
         Result := {WSF_JSON_RESPONSE}.no_content
		end

    do_delete_all (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- DELETE all resources
		do
         storage.wipe_out
				-- 204 No Content: {"message": "No Content", "status": 204}
         Result := {WSF_JSON_RESPONSE}.no_content
		end

	do_patch (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- PATCH /resource/{id} - partial update
		deferred
		end

	do_get (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /resource/{id} - retrieve single resource
		do
			Result := json_ok (storage [extract_id (req)])
		end

	do_get_all (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /resources - retrieve entire collection
		do
			Result := json_ok (all_items)
		end

    do_head (req: WSF_REQUEST ): WSF_JSON_RESPONSE
    -- HTTP HEAD on a resource: returns 200 if present, 404 otherwise
		do
         if storage.has_key (extract_id (req)) then
            Result := {WSF_JSON_RESPONSE}.ok
         else
            Result := {WSF_JSON_RESPONSE}.not_found
         end
    end





feature {NONE} -- Small helpers

	has_id_parameter (req: WSF_REQUEST): BOOLEAN
			-- Does request have a non-empty `id` path parameter?
		do
			if attached req.path_parameter ("id") as l_param and then not l_param.string_representation.is_empty then
				Result := True
			end
		end

	extract_id (req: WSF_REQUEST): PATH_PICO
			-- Storage key derived from `id` path parameter.
		require
			has_id_parameter (req)
		do
			check attached req.path_parameter ("id") as l_param then
				create Result.make_from_string ("/" + l_param.string_representation)
			end
		end

	json_ok (obj: JSON_VALUE): WSF_JSON_RESPONSE
		do
			Result := {WSF_JSON_RESPONSE}.ok.with_body (obj.representation)
		end

	all_items: JSON_ARRAY
			-- Internal helper to collect all stored items as JSON values
		do
			create Result.make_empty
			across storage.all_keys as key_cursor loop
				if attached {JSON_VALUE} storage.item (key_cursor.item) as json_val then
					Result.extend (json_val)
				end
			end
		end

   is_patch_request (req: WSF_REQUEST): BOOLEAN
         -- Is `req` using the PATCH method?
      do
         Result := req.request_method.is_case_insensitive_equal ("PATCH")
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
         if attached last_exception as l_exception then
            if attached l_exception.tag as tag then
               Result.append (tag.to_string_8)
            else
               Result.append ("Unknown")
            end
            Result.append (": ")
            if attached l_exception.description as desc then
               Result.append (desc)
            else
               Result.append ("No description available")
            end

            -- Append request method and URI
            Result.append ("%NRequest: ")
            Result.append (req.request_method)
            Result.append (" ")
            Result.append (req.request_uri)

            -- Append request body if available
            if req.raw_input_data_recorded and then attached req.raw_input_data as raw then
               Result.append ("%NBody: ")
               if raw.count > max_body_length then
                  Result.append (raw.substring (1, max_body_length))
                  Result.append ("... (truncated)")
               else
                  Result.append (raw)
               end
            end
         else
            Result.append ("No exception available")
         end
      end

   convert_exception_to_response (req: WSF_REQUEST): WSF_JSON_RESPONSE
         -- Handle exceptions based on exception type, including exception details
      local
         exception_detail: STRING
      do
         if attached last_exception as l_exception then
            exception_detail := build_exception_detail (req)

            -- Use chainable interface based on exception type
            if attached {PRECONDITION_VIOLATION} l_exception then
               Result := {WSF_JSON_RESPONSE}.precondition_failed.with_detail (exception_detail)
            elseif attached {POSTCONDITION_VIOLATION} l_exception then
               Result := {WSF_JSON_RESPONSE}.internal_server_error.with_detail (exception_detail)
            else
               -- Other exceptions - Internal Server Error with details
               Result := {WSF_JSON_RESPONSE}.internal_server_error.with_detail (exception_detail)
            end
         else
            -- No exception available
            exception_detail := build_exception_detail (req)
            Result := {WSF_JSON_RESPONSE}.internal_server_error.with_detail (exception_detail)
         end
      end

	extract_json (req: WSF_REQUEST): R
      -- Parse JSON object from request body
      require
        request_cant_be_empty: req.content_length_value > 0
		local
			json_parser: JSON_PARSER
			input_data: STRING
		do
				create input_data.make_empty
            req.read_input_data_into (input_data)
            create json_parser.make_with_string(input_data)
            if attached {R} json_parser.parse as json_obj then
            	Result := json_obj
            else
            	check attached {R} create {EJSON_JSON_OBJECT}.make_with_capacity(0) as default_obj then
            		Result := default_obj
            	end
            end
		end

end
