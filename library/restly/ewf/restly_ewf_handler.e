note
	description: "[
		Adapter that transforms EWF requests into RESTLY protocol
		calls. Speaks RESTLY on both faces: WSF_REQUEST keys in
		front, a composable [STRING, JSON_OBJECT] store behind.
		Unlike GATEWAY it keeps the container protocol
		(item/force/extend/put/remove mutating the caller's response)
		instead of switching to CALL_RETURN semantics.
		Unsafe front: the store's delivery postconditions are not
		re-promised over the wire, but the asking preconditions
		(error_404, error_409) still guard every verb via `back`.
		The wire face itself is precondition-free (require else
		True): an HTTP client is outside the contract model, so a
		contract error is a response to send, not caller blame --
		and only a caller's rescue could map a precondition, which
		would put guarding back into the routing plumbing.
	]"

class
	RESTLY_EWF_HANDLER

inherit
	RESTLY_UNSAFE_PROTOCOL [WSF_REQUEST, WSF_JSON_RESPONSE]
		rename
			remove as remove_element
		end

	ANY
			-- Re-effects default_create/copy/out/is_equal, which
			-- RESTLY_UNSAFE_PROTOCOL undefines for its own joins.

	RESTLY_CONTRACT_TO_HTTP
			-- Contract blame -> HTTP status, CORS headers.

	RESTLY_JSON_BODY

	RESTLY_COMPOSABLE [STRING, JSON_OBJECT]

create
	default_create

feature -- REST verbs

	item alias "[]" (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /resource/{id}
			-- Self-guarding: contract violations raised while asking
			-- `back` come back as the mapped error response.
		require else
			error_becomes_response: True
		do
			if not attached Result then
				Result := {WSF_JSON_RESPONSE}.ok.with_json_object (back [element_key (req)])
			end
				-- on the retry path Result was already set by handle_rescue_for_queries
		rescue
			Result := handle_rescue_for_queries
			retry
		end

	items (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /resource: everything `back` enumerates, as a bare
			-- JSON array. Every protocol speaker is traversable now,
			-- so no capability downcast.
			-- Self-guarding: a back whose cursor fails loud comes back
			-- as the mapped error response.
			-- ponytail: raw stored values; wire-schema fields (url,
			-- envelope, count) return when the schema grows back.
		local
			l_array: JSON_ARRAY
			l_cursor: TABLE_ITERATION_CURSOR [JSON_OBJECT, STRING]
		do
			if not attached Result then
				create l_array.make_empty
				from
					l_cursor := back.new_cursor
				until
					l_cursor.after
				loop
					l_array.extend (l_cursor.item)
					l_cursor.forth
				end
				Result := {WSF_JSON_RESPONSE}.ok.with_body (l_array.representation)
			end
				-- on the retry path Result was already set by handle_rescue_for_queries
		rescue
			Result := handle_rescue_for_queries
			retry
		end

	preflight_ok (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- OPTIONS: CORS preflight. Mapped explicitly because
			-- {WSF_ROUTER}'s automatic OPTIONS reply lacks
			-- "Connection: close" (~5s keep-alive stall); the CORS
			-- headers themselves come from the routing pipeline.
		do
			Result := {WSF_JSON_RESPONSE}.no_content
		end

	has_key (req: WSF_REQUEST): BOOLEAN
			-- HEAD: is the addressed element present?
		do
			Result := back.has_key (element_key (req))
		end

	extend (res: WSF_JSON_RESPONSE; req: WSF_REQUEST)
			-- POST: create the addressed element from the request body.
			-- Self-guarding: on contract violation `res` becomes the
			-- mapped error response.
		require else
			error_becomes_response: True
		local
			l_rescued: BOOLEAN
		do
			if not l_rescued then
				back.extend (parse_body (req), element_key (req))
				res.set_status_code ({HTTP_STATUS_CODE}.ok)
			end
				-- on the retry path res was already set by handle_rescue_for_command
		rescue
			l_rescued := True
			handle_rescue_for_command (res)
			retry
		end

	extend_new (res: WSF_JSON_RESPONSE; req: WSF_REQUEST)
			-- POST /resource: create an element with a server-minted key.
			-- Post/Redirect/Get: answers 303 with the fresh element's
			-- Location; the representation is the client's follow-up
			-- GET (PRG ruling, restly_ewf_design_document.org).
			-- A back that is not RESTLY_POSTABLE answers 405: the verb
			-- set of the pipeline is a conformance test.
			-- Self-guarding: on contract violation `res` becomes the
			-- mapped error response.
		local
			l_rescued: BOOLEAN
			l_json: JSON_OBJECT
			l_request_id: STRING
		do
			if not l_rescued then
				if attached {RESTLY_POSTABLE [STRING, JSON_OBJECT]} back as l_back then
					l_json := parse_body (req)
					l_request_id := l_json.out
					l_back.extend_new (l_json, l_request_id)
					check request_recorded: attached l_back.extend_requests [l_request_id] as l_new_key then
						res.set_status_code ({HTTP_STATUS_CODE}.see_other)
						res.header.put_location (element_url (req, l_new_key))
					end
				else
					res.set_status_code ({HTTP_STATUS_CODE}.method_not_allowed)
					res.set_default_json_body
				end
			end
				-- on the retry path res was already set by handle_rescue_for_command
		rescue
			l_rescued := True
			handle_rescue_for_command (res)
			retry
		end

	put (res: WSF_JSON_RESPONSE; req: WSF_REQUEST)
			-- PUT: update the addressed element from the request body.
			-- Self-guarding: on contract violation `res` becomes the
			-- mapped error response.
		require else
			error_becomes_response: True
		local
			l_rescued: BOOLEAN
		do
			if not l_rescued then
				back.put (parse_body (req), element_key (req))
				res.set_status_code ({HTTP_STATUS_CODE}.ok)
			end
				-- on the retry path res was already set by handle_rescue_for_command
		rescue
			l_rescued := True
			handle_rescue_for_command (res)
			retry
		end

	merge (res: WSF_JSON_RESPONSE; req: WSF_REQUEST)
			-- PATCH /resource/{id}: update the parts named in the
			-- request body; absent parts stay intact. Answers the
			-- updated element, read back after the merge.
			-- Self-guarding: on contract violation `res` becomes the
			-- mapped error response.
		local
			l_rescued: BOOLEAN
			l_key: STRING
		do
			if not l_rescued then
				l_key := element_key (req)
				back.merge (parse_body (req), l_key)
				res.set_status_code ({HTTP_STATUS_CODE}.ok)
				res.set_body (back [l_key].representation)
			end
				-- on the retry path res was already set by handle_rescue_for_command
		rescue
			l_rescued := True
			handle_rescue_for_command (res)
			retry
		end

	wipe_out (res: WSF_JSON_RESPONSE; req: WSF_REQUEST)
			-- DELETE /resource: remove every element `back` holds.
			-- Answers the now-empty collection, as GATEWAY did.
			-- Self-guarding: on contract violation `res` becomes the
			-- mapped error response.
		local
			l_rescued: BOOLEAN
		do
			if not l_rescued then
				back.wipe_out
				res.set_status_code ({HTTP_STATUS_CODE}.ok)
				res.set_body ("[]")
			end
				-- on the retry path res was already set by handle_rescue_for_command
		rescue
			l_rescued := True
			handle_rescue_for_command (res)
			retry
		end

	remove (res: WSF_JSON_RESPONSE; req: WSF_REQUEST)
			-- DELETE /resource/{id}
			-- Self-guarding: on contract violation `res` becomes the
			-- mapped error response.
		local
			l_rescued: BOOLEAN
		do
			if not l_rescued then
				remove_element (req)
				res.set_status_code ({HTTP_STATUS_CODE}.ok)
			end
				-- on the retry path res was already set by handle_rescue_for_command
		rescue
			l_rescued := True
			handle_rescue_for_command (res)
			retry
		end

	remove_element (req: WSF_REQUEST)
			-- Remove the element addressed by `req` from `back`.
		do
			back.remove (element_key (req))
		end

feature -- Request queries

	id_parameter_name: STRING assign set_id_parameter_name
			-- Name of the URI-template hole for element keys.
		attribute
			Result := "id"
		end

	set_id_parameter_name (a_name: STRING)
			-- Extract element keys from URI-template hole `a_name`.
		do
			id_parameter_name := a_name
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
