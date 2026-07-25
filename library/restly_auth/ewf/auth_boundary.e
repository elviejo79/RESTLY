note
	description: "[
		Authentication as a composable stage in the call/return layer:
		each verb answers 401 Unauthorized unless the request carries
		a valid credential, then delegates to `back` (typically a
		GATEWAY <| store chain). Follows the Tao (directive 1): the
		route table declares which endpoints are guarded —
			guarded := (create {AUTH_BOUNDARY}).make (codec) <| gateway <| store
		— and swapping AUTH_BOUNDARY for a bare GATEWAY is a one-word
		change (directive 12: test by shrinking).

		The clock is snapshotted once at request entry (ground rule 3)
		and threaded to the codec explicitly.
	]"

class
	AUTH_BOUNDARY

inherit
	CALL_RETURN_PROTOCOL [WSF_REQUEST, WSF_RESPONSE_MESSAGE]
		redefine
			force,
			graph_dot_lines
		end

	ANY

	CALL_RETURN_COMPOSABLE [WSF_REQUEST, WSF_RESPONSE_MESSAGE]

create
	make

feature {NONE} -- Initialization

	make (a_codec: PRINCIPAL_CODEC [CAPABILITY])
		do
			codec := a_codec
		end

feature -- Access

	codec: PRINCIPAL_CODEC [CAPABILITY]

	bearer_prefix: STRING assign set_bearer_prefix
		attribute
			Result := "Bearer "
		end

	set_bearer_prefix (a_prefix: STRING)
		do
			bearer_prefix := a_prefix
		end

feature -- REST verbs

	item alias "[]" (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
		do
			Result := guarded (req, agent back.item)
		end

	head (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
		do
			Result := guarded (req, agent back.head)
		end

	has_key (req: WSF_REQUEST): BOOLEAN
		do
			Result := back.has_key (req)
		end

	extend (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
		do
			Result := guarded (req, agent back.extend)
		end

	force (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
		do
			Result := guarded (req, agent back.force)
		end

	put (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
		do
			Result := guarded (req, agent back.put)
		end

	remove (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
		do
			Result := guarded (req, agent back.remove)
		end

feature -- REST verbs (collection)

	items (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
		do
			Result := guarded (req, agent back.items)
		end

	wipe_out (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
		do
			Result := guarded (req, agent back.wipe_out)
		end

	merge (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
		do
			Result := guarded (req, agent back.merge)
		end

	preflight_ok (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
		do
			Result := back.preflight_ok (req)
		end

feature -- Request queries

	element_key (req: WSF_REQUEST): ANY
		do
			Result := back.element_key (req)
		end

	parse_body (req: WSF_REQUEST): ANY
		do
			Result := back.parse_body (req)
		end

	id_parameter_name: STRING
		do
			Result := back.id_parameter_name
		end

feature -- Subject extraction

	subject_of (req: WSF_REQUEST): detachable STRING
			-- The authenticated subject name, if `req` carries
			-- a valid credential; Void otherwise.
		local
			l_token: STRING_8
			l_time: DATE_TIME
		do
			l_token := credential_from (req)
			create l_time.make_now_utc
			if codec.authenticated (l_token, l_time) then
				Result := codec.mint (l_token, l_time).subject
			end
		end

feature {NONE} -- Guard

	guarded (req: WSF_REQUEST; a_verb: FUNCTION [WSF_REQUEST, WSF_RESPONSE_MESSAGE]): WSF_RESPONSE_MESSAGE
		local
			l_token: STRING_8
			l_time: DATE_TIME
		do
			l_token := credential_from (req)
			create l_time.make_now_utc
			if codec.authenticated (l_token, l_time) then
				Result := a_verb (req)
			else
				Result := {WSF_JSON_RESPONSE}.unauthorized
			end
		end

	credential_from (req: WSF_REQUEST): STRING_8
		do
			if
				attached req.http_authorization as l_auth and then
				l_auth.starts_with (bearer_prefix)
			then
				Result := l_auth.substring (bearer_prefix.count + 1, l_auth.count)
			else
				create Result.make_empty
			end
		end

feature -- Output

	graph_dot_lines: STRING
		do
			create Result.make_from_string (graph_node_id)
			Result.append (" [label=%"")
			Result.append (generating_type.name)
			Result.append ("%"];%N")
			Result.append (back.graph_dot_lines)
			Result.append (graph_node_id + " -> " + back.graph_node_id + " [label=%"back%"];%N")
		end

end
