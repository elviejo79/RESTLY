note
	description: "[
		Gateway translating HTTP requests into {RESTLY_PROTOCOL} calls.
		Holds the backing pipeline and shared JSON/url helpers.
		Verb features are mapped per route via {RESTLY_EWF_CONTRACT_GUARD}.
	]"

class
	RESTLY_EWF_GATEWAY

create
	make

feature {NONE} -- Initialization

	make (a_storage: RESTLY_PROTOCOL [STRING, JSON_OBJECT])
			-- Initialize with `a_storage'.
		do
			storage := a_storage
		end

feature -- Access

	storage: RESTLY_PROTOCOL [STRING, JSON_OBJECT]
			-- Backing pipeline.

	id_parameter_name: STRING = "id"
			-- URI template variable for the element key.

feature -- Collection verbs

	get_list (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /resource — return all items as a JSON array.
		local
			l_array: JSON_ARRAY
			l_obj: JSON_OBJECT
		do
			create l_array.make_empty
			if attached {RESTLY_LISTABLE [STRING, JSON_OBJECT]} storage as l_list then
				across l_list as ic loop
					l_obj := ic
					patch_url (l_obj, element_url (req, @ ic.key))
					l_array.extend (l_obj)
				end
			end
			Result := {WSF_JSON_RESPONSE}.ok.with_body (l_array.representation)
		end

	post_new (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- POST /resource — create a new item.
		local
			l_json: JSON_OBJECT
			l_key: STRING
			l_request_id: STRING
			l_element_url: STRING
		do
			l_json := parse_json_body (req)
			create l_request_id.make (36)
			if attached req.request_time as l_time then
				l_request_id.append (l_time.out)
			end
			l_request_id.append_character ('_')
			l_request_id.append_integer (l_json.hash_code)
			if attached {RESTLY_POSTABLE [STRING, JSON_OBJECT]} storage as l_post then
				l_post.extend_new (l_json, l_request_id)
				check attached l_post.extend_requests [l_request_id] as l_new_key then
					l_key := l_new_key
				end
				l_json := storage [l_key]
				l_element_url := element_url (req, l_key)
				patch_url (l_json, l_element_url)
				Result := {WSF_JSON_RESPONSE}.created
					.with_json_object (l_json)
					.with_location (l_element_url)
			else
				Result := {WSF_JSON_RESPONSE}.method_not_allowed
			end
		end

	delete_all (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- DELETE /resource — wipe all items.
		do
			if attached {RESTLY_LISTABLE [STRING, JSON_OBJECT]} storage as l_list then
				l_list.wipe_out
			end
			Result := {WSF_JSON_RESPONSE}.ok.with_body ("[]")
		end

feature -- Element verbs

	get_one (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /resource/{id}
		local
			l_key: STRING
		do
			l_key := element_key (req)
			if storage.has_key (l_key) then
				Result := ok_element (storage [l_key], req)
			else
				Result := {WSF_JSON_RESPONSE}.not_found
			end
		end

	patch_one (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- PATCH /resource/{id}
		local
			l_key: STRING
		do
			l_key := element_key (req)
			if storage.has_key (l_key) and then attached {RESTLY_PATCHABLE [STRING, JSON_OBJECT]} storage as l_patchable then
				l_patchable.merge (parse_json_body (req), l_key)
				Result := ok_element (storage [l_key], req)
			else
				Result := {WSF_JSON_RESPONSE}.not_found
			end
		end

	delete_one (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- DELETE /resource/{id}
		local
			l_key: STRING
		do
			l_key := element_key (req)
			if storage.has_key (l_key) then
				storage.remove (l_key)
			end
			Result := {WSF_JSON_RESPONSE}.no_content
		end

feature {NONE} -- Helpers

	parse_json_body (req: WSF_REQUEST): JSON_OBJECT
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

	patch_url (a_obj: JSON_OBJECT; a_url: STRING)
			-- Add/replace "url" field with `a_url'.
		do
			a_obj.replace_with_string (a_url, "url")
		end

	element_url (req: WSF_REQUEST; a_key: READABLE_STRING_8): STRING
			-- Absolute URL of element `a_key' under the requested collection.
		do
			Result := req.absolute_script_url (req.request_uri.to_string_8 + "/" + a_key)
		end

	ok_element (a_obj: JSON_OBJECT; req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- 200 response carrying `a_obj' with its "url" set to the request URI.
		do
			patch_url (a_obj, req.absolute_script_url (req.request_uri.to_string_8))
			Result := {WSF_JSON_RESPONSE}.ok.with_json_object (a_obj)
		end

	element_key (req: WSF_REQUEST): STRING
			-- Extract the element key from the URI template match.
		do
			if attached {WSF_STRING} req.path_parameter (id_parameter_name) as l_str then
				Result := l_str.string_representation.to_string_8
			else
				Result := ""
			end
		end

end
