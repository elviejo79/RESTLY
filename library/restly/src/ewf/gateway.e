note
	description: "[
		HTTP resource handler over the wire types: translates WSF
		requests into RESTLY_PROTOCOL [STRING, JSON_OBJECT] calls
		on `back`. Store-agnostic: typed stores compose in through
		a RESTLY_CONVERTER stage:
		routes ["/todos"] := (create {GATEWAY}) <| ((create {TODO_CONVERTER}) <| my_store)
	]"

class
	GATEWAY

inherit
	CALL_RETURN_PROTOCOL [WSF_REQUEST, WSF_RESPONSE_MESSAGE]
		redefine
			force
		end

	ANY
			-- Re-effects default_create/copy/out/is_equal, which
			-- CALL_RETURN_PROTOCOL undefines for its own joins.

create
	default_create

feature -- Composition

	backed_by alias "<|" (a_back: RESTLY_PROTOCOL [ANY, ANY]): like Current
			-- Current, backed by `a_back`. When `back` is already a
			-- converter stage, `a_back` is delegated down the chain, so
			-- left-associative `<|` composes without parentheses:
			-- gateway <| converter <| store.
			-- Widened to [ANY, ANY] for that chaining: a mis-typed
			-- composition fails at runtime (precondition), not compile time.
		require
			chain_accepts_back: attached {RESTLY_CONVERTER [HASHABLE, ANY]} back as l_stage
				implies l_stage.accepts (a_back)
			leaf_speaks_wire: (not attached {RESTLY_CONVERTER [HASHABLE, ANY]} back)
				implies attached {RESTLY_PROTOCOL [STRING, JSON_OBJECT]} a_back
		do
			if attached {RESTLY_CONVERTER [HASHABLE, ANY]} back as l_stage then
				check key_is_hashable: attached {RESTLY_PROTOCOL [HASHABLE, ANY]} a_back as l_typed then
					l_stage.backed_by (l_typed).do_nothing
				end
			else
				check wire_typed_back: attached {RESTLY_PROTOCOL [STRING, JSON_OBJECT]} a_back as l_wire then
					back := l_wire
				end
			end
			Result := Current
		end

feature -- Access

	back: RESTLY_PROTOCOL [STRING, JSON_OBJECT]
			-- Backing pipeline; capability mixins (LISTABLE, POSTABLE)
			-- are discovered per verb by downcast.
		attribute
			-- ponytail: placeholder empty store until `backed_by` sets the real pipeline
			create {RESOURCE_HASH_TABLE [STRING, JSON_OBJECT]} Result.make ("unmounted")
		end

	id_parameter_name: STRING = "id"
			-- URI template variable for the element key.

feature -- REST verbs

	item alias "[]" (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /resource/{id}
		require else
			error_404: back.has_key (element_key (req))
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
			l_json, response_json: JSON_OBJECT
			l_request_id: STRING
		do
			if attached {RESTLY_POSTABLE [STRING, JSON_OBJECT]} back as l_back then
				l_json := parse_body (req)
				l_request_id := l_json.out
				l_back.extend_new (l_json, l_request_id)
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
			-- Read-modify-write in wire format: partiality is representable
			-- in JSON but not in a rigid R, so the merge happens here.
		require
			error_404: back.has_key (element_key (req))
		local
			l_key: STRING
			l_json, l_patch: JSON_OBJECT
		do
			l_key := element_key (req)
			l_json := back [l_key]
			l_patch := parse_body (req)
			across l_patch.current_keys as k loop
				l_json.replace (l_patch [k], k)
			end
			back.put (l_json, l_key)
			Result := {WSF_JSON_RESPONSE}.ok.with_json_object (back [l_key])
		end

	preflight_ok (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- CORS preflight response. Mapped explicitly because {WSF_ROUTER}'s
			-- automatic OPTIONS reply lacks "Connection: close" (~5s keep-alive stall).
		do
			Result := {WSF_JSON_RESPONSE}.no_content
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
			-- Element key addressed by `req' (URI template match).
			-- Public: used in exported preconditions (VAPE).
		do
			create Result.make_empty
			if attached {WSF_STRING} req.path_parameter (id_parameter_name) as l_str then
				Result := l_str.string_representation.to_string_8
			end
		end

end
