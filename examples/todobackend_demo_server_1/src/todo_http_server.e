note
	description: "HTTP server for TODO resources with merge-based partial updates"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TODO_HTTP_SERVER

inherit
	PICO_HTTP_SERVER [JSON_VALUE, TODO_ITEM]

create
	make

feature -- HTTP Verbs

	do_post (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- POST /todos - create new todo and return it with generated ID
		do
			storage.collection_extend (converter.to_store (extract_json (req)))
			check attached storage.last_inserted_key as last_id then
				Result := json_ok (converter.representation (storage.item (last_id)))
			end
		end

	do_put (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- PUT /todos/{id} - replace entire todo resource
		local
			id_key: PATH_PICO
			original, new: TODO_ITEM
		do
			id_key := extract_id (req)
			new := converter.to_store (extract_json (req))
			original := storage.item (id_key)
			original.merge (new)
			storage.force (original, id_key)
			Result := {WSF_JSON_RESPONSE}.ok.with_body (converter.representation (storage.item (id_key)).representation)
		end

	do_patch (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- PATCH /todos/{id} - partial update using merge semantics
		local
			id_key: PATH_PICO
			original, new: TODO_ITEM
		do
			id_key := extract_id (req)
			new := converter.to_store (extract_json (req))
			original := storage.item (id_key)
			original.merge (new)
			storage.force (original, id_key)
			Result := {WSF_JSON_RESPONSE}.ok.with_body (converter.representation (storage.item (id_key)).representation)
		end

	do_get_all (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /todos - return entire collection as JSON array
		do
			Result := json_ok (all_items)
		end

end
