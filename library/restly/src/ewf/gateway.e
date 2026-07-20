note
	description: "[
		Deferred execution that wires RESTLY pipelines to EWF.
		Inherit and implement setup_router using mount_resource
		(or the mount_collection / mount_element primitives, or
		map_verb for a fully explicit route table).
	]"

deferred class
	GATEWAY

inherit
	WSF_ROUTED_EXECUTION

	WSF_ROUTED_URI_TEMPLATE_HELPER

	CALL_RETURN_PROTOCOL [WSF_REQUEST, WSF_RESPONSE_MESSAGE]
		redefine
			force
		end

feature -- Mounting

	mount_resource (a_collection_uri: RESTLY_URI_PATH; a_storage: like back)
			-- Collection at `a_collection_uri`, element at `a_collection_uri + "/{id}"`.
		local
			l_single_element_uri: RESTLY_URI_PATH
		do
      l_single_element_uri := a_collection_uri.template + "/{" +
         id_parameter_name + "}"

         back := a_storage

			map_verb (router.methods_head_get, a_collection_uri, agent items)
			map_verb (router.methods_post,     a_collection_uri,  agent extend)
			map_verb (router.methods_delete,   a_collection_uri,  agent wipe_out)
			map_verb (router.methods_options,  a_collection_uri,  agent preflight_ok)
			map_verb (router.methods_get,      l_single_element_uri,  agent item)
			map_verb (router.methods_head,     l_single_element_uri,  agent head)
			map_verb (methods_patch,           l_single_element_uri,  agent merge)
			map_verb (router.methods_delete,   l_single_element_uri,  agent remove)
			map_verb (router.methods_options,  l_single_element_uri,  agent preflight_ok)
		end

	map_verb (a_methods: WSF_REQUEST_METHODS; a_resource_path: RESTLY_URI_PATH;  an_action: FUNCTION [WSF_REQUEST, WSF_RESPONSE_MESSAGE])
			-- Route `a_methods' requests on `a_resource_path' to `an_action'.
		do
			map_uri_template_response (a_resource_path, create {EWF_CONTRACT_GUARD}.make (an_action), a_methods)
		end

      
feature {NONE} -- Implementation

	preflight_ok (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- CORS preflight response. Mapped explicitly because {WSF_ROUTER}'s
			-- automatic OPTIONS reply lacks "Connection: close" (~5s keep-alive stall).
		do
			Result := {WSF_JSON_RESPONSE}.no_content
		end

      methods_patch: WSF_REQUEST_METHODS
   
			-- Method set containing only PATCH ({WSF_ROUTER} has no convenience query for it).
		do
			create Result
			Result.enable_patch
		end

feature -- HTTP VerbsAccess

	back: RESTLY_PROTOCOL [STRING, JSON_OBJECT]
			-- Backing pipeline; capability mixins (LISTABLE, POSTABLE,
			-- PATCHABLE) are discovered per verb by downcast.
		attribute
			-- ponytail: placeholder empty store until `mount_resource` sets the real pipeline
			create {RESOURCE_HASH_TABLE [STRING, JSON_OBJECT]} Result.make ("unmounted")
		end

	id_parameter_name: STRING = "id"
   -- URI template variable for the element key.

feature -- Basic http verbs
	item alias "[]" (req: WSF_REQUEST): WSF_JSON_RESPONSE
          -- GET /resource/{id}
      require else
         error_404: back.has_key(element_key(req))
		do
			Result := {WSF_JSON_RESPONSE}.ok.with_json_object (back [element_key (req)])
		end

      head (req: WSF_REQUEST): WSF_JSON_RESPONSE
        -- HEAD /resource/{id}
      do
         if has_key (req) then
            Result := {WSF_JSON_RESPONSE}.ok.no_content
         else
            Result := {WSF_JSON_RESPONSE}.no_content
         end
      end

      has_key (req: WSF_REQUEST): BOOLEAN
        -- Is the addressed element present?
      do
         Result := back.has_key (element_key (req))
      end

   force (req: WSF_REQUEST): WSF_JSON_RESPONSE
      -- PUT /resource/{ID} — update an item that exists or insert it
      -- this is called force in the rest of the protocol.
      -- so I've decided to keep it like that for this gateway.
      -- Redefined: delegates the upsert to `back` instead of
      -- composing inherited has_key/put/extend.
      do
         back.force (parse_body (req), element_key (req))
         Result := {WSF_JSON_RESPONSE}.ok.no_content
	end

   put (req: WSF_REQUEST): WSF_JSON_RESPONSE
      -- PUT with exists: update the addressed element.
      do
         back.put (parse_body (req), element_key (req))
         Result := {WSF_JSON_RESPONSE}.ok.no_content
      end

	extend (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- POST /resource — create a new item.
	local
      l_json,response_json: JSON_OBJECT
      l_request_id: STRING
   do
      if attached { RESTLY_POSTABLE [STRING, JSON_OBJECT]   } back as l_back then
         l_json := parse_body (req)
         l_request_id := l_json.out
            l_back.extend_new(l_json, l_request_id)
         check attached l_back.extend_requests [l_request_id] as l_new_key then
         response_json := back [l_new_key]
				Result := {WSF_JSON_RESPONSE}.created
            .with_json_object (response_json)
            .with_location (element_url (req, l_new_key))
         end
      else
        Result := {WSF_JSON_RESPONSE}.method_not_allowed
      end
	end

	wipe_out (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- DELETE /resource — wipe all items.
		do
			if attached {RESTLY_LISTABLE [STRING, JSON_OBJECT]} back as l_back then
				l_back.wipe_out
			end
			Result := {WSF_JSON_RESPONSE}.ok.with_body ("[]")
		end

	items (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /resource — return all items as a JSON array.
		local
			l_array: JSON_ARRAY
		do
			create l_array.make_empty
			if attached {RESTLY_LISTABLE [STRING, JSON_OBJECT]} back as l_list then
				across l_list as ic loop
					l_array.extend (ic)
				end
			end
			Result := {WSF_JSON_RESPONSE}.ok.with_body (l_array.representation)
		end


      
	remove (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- DELETE /resource/{id}
		local
			l_key: STRING
		do
			l_key := element_key (req)
			if back.has_key (l_key) then
				back.remove (l_key)
			end
			Result := {WSF_JSON_RESPONSE}.no_content
		end


	merge (req: WSF_REQUEST): WSF_JSON_RESPONSE
       -- PATCH /resource/{id}
      require
         error_404: back.has_key(element_key(req))
         error_405: attached {RESTLY_PATCHABLE [STRING, JSON_OBJECT]}  back
		local
			l_key: STRING
		do
			check attached {RESTLY_PATCHABLE [STRING, JSON_OBJECT]} back as l_back then
            l_key := element_key (req)
				l_back.merge (parse_body (req), l_key)
				Result := {WSF_JSON_RESPONSE}.ok.with_json_object (back [l_key])
			end
		end
      
feature {NONE} -- Helpers

	parse_body (req: WSF_REQUEST): JSON_OBJECT
			-- Parse JSON from request body.
		local
			l_input: STRING
			l_parser: JSON_PARSER
		do
			create l_input.make_empty
			req.read_input_data_into (l_input)
			create l_parser.make_with_string (l_input)
			l_parser.parse_content
			if l_parser.is_valid and then attached l_parser.parsed_json_object as l_obj then
				Result := l_obj
			else
				create Result.make_with_capacity (0)
			end
		end

	element_url (req: WSF_REQUEST; a_key: READABLE_STRING_8): STRING
			-- Absolute URL of element `a_key' under the requested collection.
		do
			Result := req.absolute_script_url (req.request_uri.to_string_8 + "/" + a_key)
		end

feature -- Helpers

	element_key (req: WSF_REQUEST): STRING
			-- Extract the element key from the URI template match.
			-- Public: used in exported preconditions (VAPE).
		do
			if attached {WSF_STRING} req.path_parameter (id_parameter_name) as l_str then
				Result := l_str.string_representation.to_string_8
			else
				Result := ""
			end
		end

      
end
