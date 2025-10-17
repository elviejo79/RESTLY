note
	description: "Summary description for {RESTFUL_HANDLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
   RESTLY_EWF_HANDLER

inherit
	WSF_URI_TEMPLATE_RESPONSE_HANDLER

	EXCEPTION_MANAGER
		export
			{NONE} all
		end

create
	make

feature {NONE} -- Initialization

	make (a_storage: REST_TABLE[JSON_OBJECT])
		do
			storage := a_storage
		end

feature {NONE} -- Fields

	storage: REST_TABLE[JSON_OBJECT]

	id_parameter_name: STRING
		attribute
			Result := "id"
		end

feature -- Access

	response (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Handle REST operations based on HTTP method
		do
      -- | TODO:
      -- Escribir el articulo
      -- hacer que en execution sólo tenga que declarar el handler una sola vez.
      -- >> [x] Esto se hace con {/id} pero entonces ahora genera una 
      -- tabla
      -- la solucion fue crear el helper function request_path
      -- >> [x] limpiar la implementación del router
      -- >> [x] usar (if expression) para limpiar el código
      -- >> >>  >> la solucion fue la funcion if_exists_execute
      -- >> [x] investigar si starts with router podría darme el resto
      -- >> >>> >>> si podría pero al final use el helper request_path
      -- [x] crear mensajes de error más amigables.
      -- >> [x] hacer que el creator sea más amigable.
			-- [X] probablemente rehacer la de WSF_JSON_RESPONSE con los constructors.
      -- exponer todos los demás metodos REST_W_STORAGE
      -- ver qué se requiere para hacerlo concurent.
      -- poner en el repositorio de código.
      -- hacer la traducción del capítulo 3
      -- hacer a single project canvas for the AI 
      -- https://antonionietorodriguez.com/project-canvas/
      
      -- If the Result was attached, it means we are in a Retry, and 
      -- must just send the Reuslt as it was managed in handle_rescue
      
      if not attached Result then --if not has_failed_before then
         if attached requested_path(req) as path  then --if we have a Path 
            -- Path-based operations (GET, PUT, DELETE)
            if req.is_get_request_method then
               Result := if_exists_execute(path, agent item(req,?))
            elseif req.is_put_request_method then
               Result := if_exists_execute(path, agent force(req,?))
            elseif req.is_delete_request_method then
               Result := if_exists_execute(path, agent remove(req,?))
            else
               Result := {WSF_JSON_RESPONSE}.method_not_allowed
            end
         elseif req.is_post_request_method then
         -- No path: only POST is valid (creates new resource)
           Result := extend (req)
         else
           Result := {WSF_JSON_RESPONSE}.method_not_allowed
         end
      end
		rescue
			Result := handle_rescue (req)
			retry
		end

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
               
feature -- Exception handling

	handle_rescue (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
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

feature {NONE} -- HTTP Handlers

	item (req: WSF_REQUEST; path: URL_PATH): WSF_JSON_RESPONSE
			-- GET resource by id
		do
			Result := create {WSF_JSON_RESPONSE}.make_with_body (storage [path].representation)
		end

	has_key (req: WSF_REQUEST; key: URL_PATH): WSF_JSON_RESPONSE
			-- Check if resource exists
		do
			if storage.has_key (key) then
				-- 200 OK
				Result := {WSF_JSON_RESPONSE}.ok
			else
				-- 404 Not Found: {"error": "Not Found", "status": 404}
				Result := {WSF_JSON_RESPONSE}.not_found
			end
		end

	extend (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- POST to create new resource
		local
			json_data: detachable JSON_OBJECT
			new_path: URL_PATH
		do
			json_data := parse_json_object (req)

			if attached json_data then
				check attached {JSON_STRING} json_data ["name"] as l_name then
					create new_path.make_from_string ("/" + l_name.unescaped_string_8)
					if not storage.has_key (new_path) then
						storage.extend (json_data, new_path)

						-- 201 Created with Location header using chainable interface
						Result := {WSF_JSON_RESPONSE}.created
							.with_json_object (json_data)
							.with_location (new_path.out)
					else
						-- 409 Conflict: Resource already exists
						Result := {WSF_JSON_RESPONSE}.conflict
							.with_detail ("Resource already exists at " + new_path.out)
					end
				end
			else
				Result := {WSF_JSON_RESPONSE}.precondition_failed
			end
		end

	force (req: WSF_REQUEST; path: URL_PATH): WSF_JSON_RESPONSE
			-- PUT to update existing resource
		do
			if attached parse_json_object (req) as json_data then
            storage.force (json_data, path)
			   -- 200 OK with updated content
			   Result := {WSF_JSON_RESPONSE}.ok.with_body (json_data.representation)
         else
            -- 400 Bad Request: {"error": "Bad Request", "status": 400}
            Result := {WSF_JSON_RESPONSE}.bad_request
         end
		end

	remove (req: WSF_REQUEST; path: URL_PATH): WSF_JSON_RESPONSE
			-- DELETE resource
		do
				storage.remove (path)
				-- 204 No Content: {"message": "No Content", "status": 204}
				Result := {WSF_JSON_RESPONSE}.no_content
		end

feature {NONE} -- Helpers

	list_all: WSF_JSON_RESPONSE
			-- Return all resources as JSON array
		local
			json_array: JSON_ARRAY
			obj: JSON_OBJECT
		do
			create json_array.make (storage.count)
			across
				storage as c
			loop
				create obj.make
				-- "key" field
				obj.put (create {JSON_STRING}.make_from_string (c.key.out), "key")
				-- "value" field (number)
				obj.put (c.item, "value")
				json_array.extend (obj)
			end

			Result := create {WSF_JSON_RESPONSE}.make_with_body (json_array.representation)
		end

	parse_json_object (req: WSF_REQUEST): detachable JSON_OBJECT
			-- Parse JSON object from request body
		local
			json_parser: JSON_PARSER
			input_data: STRING
		do
			if req.content_length_value > 0 then
				create input_data.make_empty
				req.read_input_data_into (input_data)
				create json_parser.make_with_string (input_data)
				json_parser.parse_content
				if attached {JSON_OBJECT} json_parser.parsed_json_value as jo then
					Result := jo
				end
			end
			-- Returns Void if parsing fails or no content
		end

   if_exists_execute (path: URL_PATH; handler: FUNCTION [URL_PATH, WSF_JSON_RESPONSE]): WSF_JSON_RESPONSE
      -- Execute handler if path exists, otherwise return 404
    do
      if storage.has_key(path) then
        Result := handler.item (path)
      else
        Result := {WSF_JSON_RESPONSE}.not_found
      end
    end

end
