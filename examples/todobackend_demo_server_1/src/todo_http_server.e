note
	description: "HTTP server for TODO resources with merge-based partial updates"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TODO_HTTP_SERVER

inherit
	PICO_HTTP_SERVER [JSON_VALUE, TODO_ITEM]
		redefine
			do_put
		end

create
	make

feature -- HTTP Verbs

	do_put (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- PUT /todos/{id} - merge update (treats PUT as PATCH for TodoBackend spec)
		do
			Result := do_patch (req)
		end

	do_patch (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- PATCH /todos/{id} - partial update via merge
		local
			id_key: PATH_PICO
		do
			id_key := extract_id (req)
			storage.merge_update (extract_json (req), id_key)
			Result := json_ok (storage.item (id_key))
		end

end
