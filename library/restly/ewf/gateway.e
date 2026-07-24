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

	RESTLY_JSON_BODY
			-- Body parsing, envelope wrapping, and the four wire-schema
			-- knobs; adopted from `back` at composition.

	RESTLY_COMPOSABLE [STRING, JSON_OBJECT]
		redefine
			make_with_back
		end

create
	default_create

feature -- REST verbs

	item alias "[]" (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /resource/{id}
		require else
			error_404: back.has_key (element_key (req))
		do
			Result := {WSF_JSON_RESPONSE}.ok.with_json_object (element_representation (req, element_key (req)))
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
			-- Post/Redirect/Get: the command answers only the location
			-- of the fresh element; the representation is the client's
			-- follow-up GET (see restly_ewf_design_document.org, PRG
			-- ruling experiment 2026-07-23).
		local
			l_json: JSON_OBJECT
			l_request_id: STRING
		do
			if attached {RESTLY_POSTABLE [STRING, JSON_OBJECT]} back as l_back then
				l_json := parse_body (req)
				l_request_id := l_json.out
				l_back.extend_new (l_json, l_request_id)
				check attached l_back.extend_requests [l_request_id] as l_new_key then
					Result := {WSF_JSON_RESPONSE}.see_other
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
			-- GET /resource — all items as a JSON array, wrapped in
			-- `collection_envelope` (plus a count field) if set.
		local
			l_array: JSON_ARRAY
			l_cursor: TABLE_ITERATION_CURSOR [JSON_OBJECT, STRING]
			l_wrap: JSON_OBJECT
		do
			create l_array.make_empty
			if attached {RESTLY_LISTABLE [STRING, JSON_OBJECT]} back as l_list then
				from
					l_cursor := l_list.new_cursor
				until
					l_cursor.after
				loop
					l_array.extend (represented (l_cursor.item, req, l_cursor.key))
					l_cursor.forth
				end
			end
			if attached collection_envelope as l_name then
				create l_wrap.make_with_capacity (2)
				l_wrap.put (l_array, l_name)
				l_wrap.put (create {JSON_NUMBER}.make_integer (l_array.count), l_name + "Count")
				Result := {WSF_JSON_RESPONSE}.ok.with_json_object (l_wrap)
			else
				Result := {WSF_JSON_RESPONSE}.ok.with_body (l_array.representation)
			end
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
			-- Delegates to the back's RESTLY_PATCHABLE.merge, which
			-- does the read-modify-write in JSON space.
		require else
			error_404: back.has_key (element_key (req))
		local
			l_key: STRING
		do
			l_key := element_key (req)
			if attached {RESTLY_PATCHABLE [STRING, JSON_OBJECT]} back as l_back then
				l_back.merge (parse_body (req), l_key)
			end
			Result := {WSF_JSON_RESPONSE}.ok.with_json_object (element_representation (req, l_key))
		end

	preflight_ok (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- CORS preflight response. Mapped explicitly because {WSF_ROUTER}'s
			-- automatic OPTIONS reply lacks "Connection: close" (~5s keep-alive stall).
		do
			Result := {WSF_JSON_RESPONSE}.no_content
		end

feature {NONE} -- Helpers

	represented (a_json: JSON_OBJECT; req: WSF_REQUEST; a_key: STRING): JSON_OBJECT
			-- `a_json` plus the address-derived fields (`key_field`,
			-- `url_field`) in a fresh object: injecting into `a_json`
			-- itself would alias the fields back into the store.
		local
			l_string: JSON_STRING
		do
			if key_field = Void and url_field = Void then
				Result := a_json
			else
				create Result.make_with_capacity (a_json.count + 2)
				across a_json.current_keys as k loop
					Result.put (a_json [k], k)
				end
				if attached key_field as l_field then
					l_string := a_key
					Result.replace (l_string, l_field)
				end
				if attached url_field as l_field then
					l_string := element_url (req, a_key)
					Result.replace (l_string, l_field)
				end
			end
		end

	element_representation (req: WSF_REQUEST; a_key: STRING): JSON_OBJECT
			-- Representation of element `a_key`: stored value plus derived
			-- fields, wrapped in `element_envelope` if set.
		local
			l_inner: JSON_OBJECT
		do
			l_inner := represented (back [a_key], req, a_key)
			if attached element_envelope as l_name then
				create Result.make_with_capacity (1)
				Result.put (l_inner, l_name)
			else
				Result := l_inner
			end
		end

	element_url (req: WSF_REQUEST; a_key: READABLE_STRING_8): STRING
			-- Absolute URL of element `a_key' under the requested collection.
			-- Element-addressed requests carry the key as the last URI
			-- segment; strip it, or the key would be appended twice.
		local
			l_uri: STRING
		do
			l_uri := req.request_uri.to_string_8
			if attached req.path_parameter (id_parameter_name) then
				l_uri.keep_head (l_uri.last_index_of ('/', l_uri.count) - 1)
			end
			Result := req.absolute_script_url (l_uri + "/" + a_key)
		end

feature -- Helpers

	id_parameter_name: STRING assign set_id_parameter_name
			-- Name of the URI-template hole for element keys
			-- (RESTLY_ROUTES mounts elements at a_uri + "/{id}").
		attribute
			Result := "id"
		end

	set_id_parameter_name (a_name: STRING)
			-- Extract element keys from URI-template hole `a_name`.
		do
			id_parameter_name := a_name
		end

feature -- Composition

	make_with_back (a_back: like back)
			-- <Precursor>; adopt the wire-schema names declared by
			-- `a_back` (the codec or store directly behind this
			-- gateway) for any knob not set explicitly here.
		do
			Precursor (a_back)
			if attached {RESTLY_WIRE_SCHEMA} a_back as l_schema then
				if element_envelope = Void then
					element_envelope := l_schema.element_envelope
				end
				if collection_envelope = Void then
					collection_envelope := l_schema.collection_envelope
				end
				if key_field = Void then
					key_field := l_schema.key_field
				end
				if url_field = Void then
					url_field := l_schema.url_field
				end
			end
		end

feature -- Helpers

	element_key (req: WSF_REQUEST): STRING
			-- Element key addressed by `req' (URI template match).
			-- Public: used in exported preconditions (VAPE).
		do
			if attached {WSF_STRING} req.path_parameter (id_parameter_name) as l_id then
				Result := l_id.value.to_string_8
			else
				create Result.make_empty
			end
		end
end
