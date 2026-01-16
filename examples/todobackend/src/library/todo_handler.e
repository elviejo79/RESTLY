note
	description: "TODO-specific REST resource handler implementation"

class
	TODO_HANDLER

inherit
	PICO_RESOURCE_HANDLER[TODO_ITEM]

create
	make_with_backend

feature {NONE} -- Initialization

	make_with_backend (a_backend: like backend; a_base_url: STRING)
		do
			backend := a_backend
			base_url := a_base_url
		end

feature {NONE} -- Backend implementation

	backend: PICO_VERBS[TODO_ITEM, JSON_OBJECT]
			-- The storage backend for resources

	base_url: STRING
			-- Base URL for building resource URLs

feature {NONE} -- HTTP Verbs implementation

	do_get (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /resource/{id} - retrieve single resource
		local
			item: TODO_ITEM
		do
			item := backend.item (extract_id (req))
			Result := json_ok (item.to_json_value)
		end

	do_get_all (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /resource - retrieve all resources
		do
			Result := json_ok (all_items)
		end

	do_post (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- POST /resource - create new resource
		local
			updated_item: TODO_ITEM
			jo: JSON_OBJECT
		do
			jo := extract_json (req)
			backend.extend_from_patch (jo)
			updated_item := backend.item (backend.last_modified_key)
			Result := {WSF_JSON_RESPONSE}.created.with_body (
				updated_item.to_json_value.representation
			)
		end

	do_put (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- PUT /resource/{id} - replace entire resource
		do
			Result := do_patch (req)
		end

	do_patch (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- PATCH /resource/{id} - partial update
		local
			id: PATH
			partial: JSON_OBJECT
			l_res: TODO_ITEM
		do
			id := extract_id (req)
			partial := extract_json (req)
			backend.patch (partial, id)
			l_res := backend.item (id)
			Result := json_ok (l_res.to_json_value)
		end

	do_delete (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- DELETE /resource/{id}
		do
			backend.remove (extract_id (req))
			Result := {WSF_JSON_RESPONSE}.no_content
		end

	do_delete_all (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- DELETE /resource - delete all
		do
			backend.wipe_out
			Result := {WSF_JSON_RESPONSE}.no_content
		end

	do_head (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- HTTP HEAD on a resource: returns 200 if present, 404 otherwise
		do
			if backend.has (extract_id (req)) then
				Result := {WSF_JSON_RESPONSE}.ok
			else
				Result := {WSF_JSON_RESPONSE}.not_found
			end
		end

feature {NONE} -- Helpers

	all_items: JSON_ARRAY
			-- Collect all stored items as JSON array
		do
			create Result.make_empty
			across backend.linear_representation as item loop
				Result.extend (item.to_json_value)
			end
		end

	build_url_for (id: PATH): STRING
			-- Build full URL for a resource
		do
			Result := base_url + id.out
		end

end
