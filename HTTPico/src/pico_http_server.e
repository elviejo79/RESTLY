note
	description: "Exposes HTTTPico Resources to the web. This is the complement of PICO_HTTP_CLIENT"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
   PICO_HTTP_SERVER[R -> JSON_VALUE, S -> PICO_ENTITY]

inherit
	WSF_URI_TEMPLATE_RESPONSE_HANDLER

	EXCEPTION_MANAGER
		export
			{NONE} all
		end
   
create
	make

feature {NONE} -- Initialization

	make (a_storage: like storage; a_converter:PICO_CONVERTER[R,S])
		do
      storage := a_storage
         conv := a_converter
		end

feature
conv: PICO_CONVERTER[R,S]
   
feature {NONE} -- Fields

	storage: PICO_TABLE[S]

	id_parameter_name: STRING
		attribute
			Result := "id"
		end

feature -- Access

response (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
    local
        id: PATH_PICO
        has_id: BOOLEAN
    do
        -- Try to extract id
        if attached req.path_parameter ("id") as l_param and then not l_param.string_representation.is_empty then
			create id.make_from_string(l_param.string_representation)
            has_id := True
        else
            has_id := False
        end

        if req.is_options_request_method then
            -- OPTIONS (CORS preflight)
            Result := {WSF_JSON_RESPONSE}.ok
        elseif req.is_get_request_method and has_id then
            -- GET /resource/{id}
            Result := do_get(req)
        elseif req.is_get_request_method and not has_id then
            -- GET /resources it should return the whole collection
            Result := do_get_all(req)
        elseif req.is_put_request_method and has_id then
            -- PUT /resource/id
            Result := do_patch(req)
        elseif req.request_method.is_case_insensitive_equal ("PATCH") and has_id then
            -- PATCH /resource/id
            Result := do_patch(req)
        elseif req.is_delete_request_method and has_id then
            -- DELETE /resource/id
            Result := do_delete(req)
        elseif req.is_post_request_method and not has_id then
            -- POST /resource
            Result := do_post(req)
        elseif req.is_delete_request_method and not has_id then
            -- DELETE /resources - delete all
            Result := do_delete_all(req)
        else
            -- Anything else
            Result := {WSF_JSON_RESPONSE}.method_not_allowed
        end
    end

feature -- verbs like PICO_REQUEST_VERBS but all of them return messages;

feature
   do_post (req: WSF_REQUEST): WSF_JSON_RESPONSE
      do
         if not attached Result then
            storage.collection_extend (conv.to_store(extract_json(req)))
            check attached storage.last_inserted_key as last_id then

                  Result := json_ok (conv.representation(storage.item(last_id)))
               end
       end
     rescue
        Result := convert_exception_to_response(req)
     retry
    end

    do_delete (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- DELETE resource
		do
         if not attached Result then
				storage.remove (extract_id(req))
				-- 204 No Content: {"message": "No Content", "status": 204}
            Result := {WSF_JSON_RESPONSE}.no_content
         end
      rescue
        Result := convert_exception_to_response(req)
        retry
		end

    do_delete_all (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- DELETE all resources
		do
         if not attached Result then
				storage.wipe_out
				-- 204 No Content: {"message": "No Content", "status": 204}
            Result := {WSF_JSON_RESPONSE}.no_content
         end
      rescue
        Result := convert_exception_to_response(req)
        retry
		end

    do_patch (req: WSF_REQUEST): WSF_JSON_RESPONSE
      -- PATCH resource with partial update
      local
      id_key: PATH_PICO
         original, new : S
		do
         if not attached Result then
            id_key := extract_id(req)
            new := conv.to_store(extract_json(req))
            original := storage.item(id_key)
            original.merge(new)
            storage.force(original, id_key)

            Result := {WSF_JSON_RESPONSE}.ok.with_body (conv.representation(storage.item(id_key)).representation)
         end
      rescue
         Result := convert_exception_to_response(req)
         retry
		end

   do_get (req: WSF_REQUEST ): WSF_JSON_RESPONSE
		do
         if not attached Result then
           Result := json_ok (conv.representation(storage[extract_id(req)]))
       end
     rescue
        Result := convert_exception_to_response(req)
     retry
    end

    all_items:JSON_ARRAY
      do
      create Result.make_empty
         across storage as c loop
             Result.extend (conv.representation(c.item))
      end
      end


    do_get_all (req: WSF_REQUEST ): WSF_JSON_RESPONSE
    -- http get /todos Should return a json array of all the collection
	   do
         if not attached Result then
           Result := json_ok (all_items)
       end
     rescue
        Result := convert_exception_to_response(req)
     retry
    end

    do_head (req: WSF_REQUEST ): WSF_JSON_RESPONSE
    -- http get /todos Should return a json array of all the collection
		do
         if not attached Result then
           Result := (if storage.has_key(extract_id(req)) then {WSF_JSON_RESPONSE}.ok  else {WSF_JSON_RESPONSE}.not_found end)
       end
     rescue
        Result := convert_exception_to_response(req)
     retry
    end





feature {NONE} -- Small helpers

	merge_json (original, patch: R): R
			-- Merge patch fields into original JSON object
		local
			parser: JSON_PARSER
		do
			-- Convert to string representation and reparse
			-- PATCH semantics: merge patch fields over original
			-- For now, use a simple approach via JSON_CORE library
			create parser.make_with_string (original.representation)
			parser.parse_content

			if attached {R} parser.parsed_json_value as orig then
				create parser.make_with_string (patch.representation)
				parser.parse_content

				if attached {R} parser.parsed_json_value as patch_val then
					Result := do_merge(orig, patch_val)
				else
					Result := orig
				end
			else
				Result := original
			end
		end

	do_merge (base, overlay: R): R
			-- Merge overlay JSON fields into base
		local
			parser: JSON_PARSER
			merged_repr: STRING
		do
			-- Parse both base and overlay to work with them
			create parser.make_with_string (base.representation)
			parser.parse_content

			if attached parser.parsed_json_value as base_val then
				create parser.make_with_string (overlay.representation)
				parser.parse_content

				if attached parser.parsed_json_value as overlay_val then
					-- Perform the merge by manipulating the string representation
					-- For now, use a simple approach: overlay wins
					-- TODO: Implement proper field-by-field merging
					create merged_repr.make_from_string (base.representation)

					-- This is a simplified merge - just return overlay for non-empty fields
					Result := overlay
				else
					Result := base
				end
			else
				Result := base
			end
		end

    json_ok (obj: JSON_VALUE): WSF_JSON_RESPONSE
        do
            Result := {WSF_JSON_RESPONSE}.ok.with_body (obj.representation)
        end

    json_error (msg: READABLE_STRING_8): WSF_JSON_RESPONSE
        do
            Result := {WSF_JSON_RESPONSE}.bad_request.with_detail (msg)
        end

   convert_exception_to_response (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- Handle exceptions based on exception type, including exception details
		local
			exception_detail: STRING
		do
			if attached last_exception as l_exception then
				-- Build exception detail string
				create exception_detail.make (100)
				if attached l_exception.tag as tag then
					exception_detail.append (tag.to_string_8)
				else
					exception_detail.append ("Unknown")
				end
				exception_detail.append (": ")
				if attached l_exception.description as desc then
					exception_detail.append (desc)
				else
					exception_detail.append ("No description available")
				end

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
				Result := {WSF_JSON_RESPONSE}.internal_server_error
			end
		end







--- original

feature requested_path(req: WSF_REQUEST): detachable URL_PATH
      local
      full_path : STRING_32
do
				if attached req.path_parameter (id_parameter_name) as path_param then
					if attached {WSF_TABLE} path_param as tb then
                  create full_path.make_empty
                  across tb is segment
                   loop
                      full_path.append_character ('/')
                      full_path.append (segment.string_representation)
               end
                  create Result.make_from_string(full_path)
					elseif attached {WSF_STRING} path_param as fv then
                  if not fv.string_representation.is_empty then
                     create Result.make_from_string ("/" + fv.string_representation)
                  end
					end
            end
            end


feature {NONE} -- Helpers that get information from the request.

   extract_id(req:WSF_REQUEST):PATH_PICO
      require
        id_must_be_part_of_path: attached req.path_parameter("id")
      local
         id_as_int: INTEGER
      do
         if attached req.path_parameter("id") as l_param then
            print ("%N=== Debug path_parameter(id) ===%N")
            print ("Type: " + l_param.generating_type.name + "%N")
            print ("String representation: " + l_param.string_representation + "%N")
            if attached {WSF_TABLE} l_param as l_table then
               print ("It's a WSF_TABLE, getting first_value%N")
               if attached l_table.first_value as fv then
                  print ("First value type: " + fv.generating_type.name + "%N")
                  print ("First value string: " + fv.string_representation + "%N")
               end
            end
         end
         check attached {WSF_TABLE} req.path_parameter("id") as l_table and then
            attached {WSF_STRING} l_table.first_value as l_id then
            id_as_int := l_id.integer_value
            create Result.make_from_string("/" + id_as_int.out)
               print ("%N this is the parameter %N")
               print (id_as_int.out + "%N")
               print (Result.out + "%N")
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
