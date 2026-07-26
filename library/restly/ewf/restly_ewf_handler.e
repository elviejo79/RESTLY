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
		do
			if not attached Result then
				Result := {WSF_JSON_RESPONSE}.ok.with_json_object (back [element_key (req)])
			end
				-- on the retry path Result was already set by handle_rescue_for_queries
		rescue
			Result := handle_rescue_for_queries
			retry
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
		local
			l_rescued: BOOLEAN
		do
			if not l_rescued then
				back.extend (parse_body (req), element_key (req))
				res.set_ok
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
		local
			l_rescued: BOOLEAN
		do
			if not l_rescued then
				back.put (parse_body (req), element_key (req))
				res.set_ok
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
				res.set_ok
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
