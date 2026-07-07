note
	description: "[
		Collection verb provider.
		Verbs: GET (list), POST, DELETE (wipe_out).
	]"

class
	RESTLY_EWF_COLLECTION_HANDLER

inherit
	RESTLY_EWF_HANDLER

create
	make

feature -- Verb handlers

	get_list (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /resource — return all items as a JSON array.
		local
			l_array: JSON_ARRAY
			l_obj: JSON_OBJECT
		do
			create l_array.make_empty
			if attached {RESTLY_LISTABLE [STRING, JSON_OBJECT]} storage as l_trav then
				across l_trav as ic loop
					l_obj := ic
					patch_url (l_obj, @ ic.key, req)
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
		do
			l_json := parse_json_body (req)
			create l_request_id.make (36)
			if attached req.request_time as l_time then
				l_request_id.append (l_time.out)
			end
			l_request_id.append_character ('_')
			l_request_id.append_integer (l_json.hash_code)
			if attached {RESTLY_POSTABLE [STRING, JSON_OBJECT]} storage as l_ext then
				l_ext.extend_new (l_json, l_request_id)
				check attached l_ext.extend_requests [l_request_id] as l_new_key then
					l_key := l_new_key
				end
				l_json := storage [l_key]
				patch_url (l_json, l_key, req)
				Result := {WSF_JSON_RESPONSE}.created
					.with_json_object (l_json)
					.with_location (req.absolute_script_url (element_uri (l_key, req)))
			else
				Result := {WSF_JSON_RESPONSE}.method_not_allowed
			end
		end

	delete_all (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- DELETE /resource — wipe all items.
		do
			if attached {RESTLY_LISTABLE [STRING, JSON_OBJECT]} storage as l_trav then
				l_trav.wipe_out
			end
			Result := {WSF_JSON_RESPONSE}.ok.with_body ("[]")
		end

feature {NONE} -- Helpers

	element_uri (a_key: STRING; req: WSF_REQUEST): STRING
			-- <Precursor>
		do
			Result := req.request_uri.to_string_8 + "/" + a_key
		end

end
