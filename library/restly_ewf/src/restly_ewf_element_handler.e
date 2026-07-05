note
	description: "[
		Element endpoint handler.
		Verbs: GET (one), PATCH, DELETE (one), OPTIONS.
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

feature {NONE} -- Dispatch

	dispatch (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- <Precursor>
		do
			if req.is_get_request_method then
				Result := get_one (req)
			elseif req.is_request_method ("PATCH") then
				Result := patch_one (req)
			elseif req.is_delete_request_method then
				Result := delete_one (req)
			else
				Result := {WSF_JSON_RESPONSE}.method_not_allowed
			end
		end

feature {NONE} -- Verb handlers

	get_one (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /resource/{id}
		local
			l_key: STRING
			l_obj: JSON_OBJECT
		do
			l_key := element_key (req)
			l_obj := storage [l_key]
			patch_url (l_obj, l_key, req)
			Result := {WSF_JSON_RESPONSE}.ok.with_json_object (l_obj)
		end

	patch_one (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- PATCH /resource/{id}
		local
			l_key: STRING
			l_patch: JSON_OBJECT
			l_result_obj: JSON_OBJECT
		do
			l_key := element_key (req)
			l_patch := parse_json_body (req)
			if attached {RESTLY_PATCHABLE [STRING, JSON_OBJECT]} storage as l_patchable then
				l_patchable.merge (l_patch, l_key)
				l_result_obj := storage [l_key]
				patch_url (l_result_obj, l_key, req)
				Result := {WSF_JSON_RESPONSE}.ok.with_json_object (l_result_obj)
			else
				Result := {WSF_JSON_RESPONSE}.method_not_allowed
			end
		end

	delete_one (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- DELETE /resource/{id}
		do
			storage.remove (element_key (req))
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
