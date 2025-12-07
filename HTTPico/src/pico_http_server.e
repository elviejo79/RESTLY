note
	description: "Exposes HTTTPico Resources to the web. This is the complement of PICO_HTTP_CLIENT"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
   PICO_HTTP_SERVER

inherit
	WSF_URI_TEMPLATE_RESPONSE_HANDLER

	EXCEPTION_MANAGER
		export
			{NONE} all
		end

create
	make

feature {NONE} -- Initialization

	make (a_storage: like storage)
		do
			storage := a_storage
		end

feature {NONE} -- Fields

	storage: PICO_TABLE[JSON_OBJECT]

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
        -- Try to extract id (or PATH_PICO, or whatever your key is)
        if attached {PATH_PICO} req.path_parameter ("id") as l_id then
            has_id := True
            id := l_id
        else
            has_id := False
        end

        if req.is_get_request_method and has_id then
            -- GET /resource/{id}
            Result := do_get(req)
        elseif req.is_get_request_method and not has_id then
            -- GET /resources it should return the whole collection
            Result := do_get_all(req)
        elseif req.is_put_request_method and has_id then
            -- PUT /resource/id
              Result := do_patch(req)
        elseif req.is_delete_request_method and has_id then
            -- DELETE /resource/id
            Result := do_delete(req)
        elseif req.is_post_request_method and not has_id then
            -- POST /resource
            Result := do_post(req)
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
            storage.collection_extend (extract_json(req))
               check attached storage.last_inserted_key as last_id then
                  Result := json_ok (storage.item(last_id))
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

    do_patch (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- DELETE resource
		do
         if not attached Result then
            storage.force(extract_json(req), extract_id(req))
            Result := {WSF_JSON_RESPONSE}.ok.with_body (storage.item(extract_id(req)).representation)
         end
      rescue
      Result := convert_exception_to_response(req)
      retry   
		end

   do_get (req: WSF_REQUEST ): WSF_JSON_RESPONSE
		do
         if not attached Result then
           Result := json_ok (storage[extract_id(req)])
       end
     rescue
        Result := convert_exception_to_response(req)
     retry   
    end

    all_items:JSON_ARRAY
      local
      values: ARRAYED_LIST [JSON_OBJECT]
      do
      values := storage.linear_representation -- HASH_TABLE[JSON_OBJECT, …]
      create Result.make (values.count)     -- pre-size the array
      across values as c loop
          Result.extend (c.item)
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
      do
         check attached {STRING} req.path_parameter("id") as l_id then
            create Result.make_from_string(l_id)
               end
      end

	extract_json (req: WSF_REQUEST): JSON_OBJECT
      -- Parse JSON object from request body
      require
        request_cant_be_empty: req.content_length_value > 0
		local
			json_parser: JSON_PARSER
			input_data: STRING
		do
				create input_data.make_empty
            req.read_input_data_into (input_data)
            create Result.make_from_string(input_data)
		end

end
