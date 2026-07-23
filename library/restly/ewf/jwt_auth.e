note
	description: "[
		JWT bearer-token guard over a call/return handler: each verb
		answers 401 Unauthorized unless the request carries a valid
		token, then delegates to `back` (typically a GATEWAY).
		routes ["/todos"] := (create {JWT_AUTH}.make (secret)) <| (create {GATEWAY}) <| codec <| store
	]"

class
	JWT_AUTH

inherit
	CALL_RETURN_PROTOCOL [WSF_REQUEST, WSF_RESPONSE_MESSAGE]
		redefine
			force,
			graph_dot_lines
		end

	ANY
			-- Re-effects default_create/copy/out/is_equal, which
			-- CALL_RETURN_PROTOCOL undefines for its own joins.

	CALL_RETURN_COMPOSABLE [WSF_REQUEST, WSF_RESPONSE_MESSAGE]

create
	default_create, make

feature -- Creation

	make (a_secret: READABLE_STRING_8)
			-- Guard verifying HS256 signatures against `a_secret`.
		do
			secret := a_secret
		end

feature -- Access

	secret: READABLE_STRING_8
			-- HMAC key tokens must be signed with.
		attribute
			create {STRING_8} Result.make_empty
		end

	algorithm: STRING = "HS256"
			-- Pinned signature algorithm: trusting the token's own
			-- header alg would accept unsigned ("none") tokens.

	bearer_prefix: STRING = "Bearer "

feature -- Status report

	is_authorized (req: WSF_REQUEST): BOOLEAN
			-- Does `req` carry a valid bearer token?
		do
			if
				attached req.http_authorization as l_auth and then
				l_auth.starts_with (bearer_prefix)
			then
				Result := is_valid_token (l_auth.substring (bearer_prefix.count + 1, l_auth.count))
			end
		end

	is_valid_token (a_token: READABLE_STRING_8): BOOLEAN
			-- Is `a_token` a JWT signed with `secret`?
		do
			Result := attached (create {JWT_LOADER}).token (a_token, algorithm, secret, Void) as l_tok
				and then not l_tok.has_error
		end

feature -- REST verbs

	item alias "[]" (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- <Precursor>
		do
			if is_authorized (req) then
				Result := back [req]
			else
				Result := unauthorized
			end
		end

	head (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- <Precursor>
		do
			if is_authorized (req) then
				Result := back.head (req)
			else
				Result := unauthorized
			end
		end

	has_key (req: WSF_REQUEST): BOOLEAN
			-- <Precursor>: presence is `back`'s business.
		do
			Result := back.has_key (req)
		end

	extend (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- <Precursor>
		do
			if is_authorized (req) then
				Result := back.extend (req)
			else
				Result := unauthorized
			end
		end

	force (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- <Precursor>
			-- Redefined: delegates the upsert whole to `back` — the
			-- inherited has_key/put/extend composition would turn a
			-- keyed PUT-insert into a key-minting POST at the gateway.
		do
			if is_authorized (req) then
				Result := back.force (req)
			else
				Result := unauthorized
			end
		end

	put (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- <Precursor>
		do
			if is_authorized (req) then
				Result := back.put (req)
			else
				Result := unauthorized
			end
		end

	remove (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- <Precursor>
		do
			if is_authorized (req) then
				Result := back.remove (req)
			else
				Result := unauthorized
			end
		end

feature -- REST verbs (collection)

	items (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- <Precursor>
		do
			if is_authorized (req) then
				Result := back.items (req)
			else
				Result := unauthorized
			end
		end

	wipe_out (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- <Precursor>
		do
			if is_authorized (req) then
				Result := back.wipe_out (req)
			else
				Result := unauthorized
			end
		end

	merge (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- <Precursor>
		do
			if is_authorized (req) then
				Result := back.merge (req)
			else
				Result := unauthorized
			end
		end

	preflight_ok (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- <Precursor>: unguarded — CORS preflights carry no credentials.
		do
			Result := back.preflight_ok (req)
		end

feature -- Request queries

	element_key (req: WSF_REQUEST): ANY
			-- <Precursor>
		do
			Result := back.element_key (req)
		end

	parse_body (req: WSF_REQUEST): ANY
			-- <Precursor>
		do
			Result := back.parse_body (req)
		end

	id_parameter_name: STRING
			-- <Precursor>
		do
			Result := back.id_parameter_name
		end

feature {NONE} -- Responses

	unauthorized: WSF_RESPONSE_MESSAGE
			-- 401 with no body.
		do
			Result := {WSF_JSON_RESPONSE}.unauthorized
		end

feature -- Output

	graph_dot_lines: STRING
			-- <Precursor>: self node plus edge to `back`.
		do
			create Result.make_from_string (graph_node_id)
			Result.append (" [label=%"")
			Result.append (generating_type.name)
			Result.append ("%"];%N")
			Result.append (back.graph_dot_lines)
			Result.append (graph_node_id + " -> " + back.graph_node_id + " [label=%"back%"];%N")
		end

end
