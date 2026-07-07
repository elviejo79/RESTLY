note
	description: "[
		Element verb provider.
		Verbs: GET (one), PATCH, DELETE (one).
	]"

class
	RESTLY_EWF_ELEMENT_HANDLER

inherit
	RESTLY_EWF_HANDLER

create
	make

feature -- Access

	id_parameter_name: STRING = "id"
			-- URI template variable for the element key.

feature -- Verb handlers

	get_one (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /resource/{id}
		local
			l_key: STRING
			l_obj: JSON_OBJECT
		do
			l_key := element_key (req)
			if storage.has_key (l_key) then
				l_obj := storage [l_key]
				patch_url (l_obj, l_key, req)
				Result := {WSF_JSON_RESPONSE}.ok.with_json_object (l_obj)
			else
				Result := {WSF_JSON_RESPONSE}.not_found
			end
		end

	patch_one (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- PATCH /resource/{id}
		local
			l_key: STRING
			l_patch: JSON_OBJECT
			l_result_obj: JSON_OBJECT
		do
			l_key := element_key (req)
			if storage.has_key (l_key) and then attached {RESTLY_PATCHABLE [STRING, JSON_OBJECT]} storage as l_patchable then
				l_patch := parse_json_body (req)
				l_patchable.merge (l_patch, l_key)
				l_result_obj := storage [l_key]
				patch_url (l_result_obj, l_key, req)
				Result := {WSF_JSON_RESPONSE}.ok.with_json_object (l_result_obj)
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

	element_key (req: WSF_REQUEST): STRING
			-- Extract the element key from the URI template match.
		do
			if attached {WSF_STRING} req.path_parameter (id_parameter_name) as l_str then
				Result := l_str.string_representation.to_string_8
			else
				Result := ""
			end
		end

	element_uri (a_key: STRING; req: WSF_REQUEST): STRING
			-- <Precursor>
		do
			Result := req.request_uri.to_string_8
		end

end
