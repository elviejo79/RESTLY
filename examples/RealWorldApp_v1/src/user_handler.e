note
	description: "[
		HTTP adapter for user endpoints. Composes with USER_STORE
		via <| (backed_by), delegates JWT extraction to a shared
		AUTH_BOUNDARY instance. Four features, one per operationId.
		Commands (register, login) return PRG 303 (CQS-aligned).
		Queries (current_user, update_user) return 200.
	]"

class
	USER_HANDLER

inherit
	RESTLY_COMPOSABLE [STRING, JSON_OBJECT]
		redefine
			make_with_back
		end

	RESTLY_JSON_BODY
		redefine
			wrapped
		end

create
	make

feature {NONE} -- Initialization

	make (a_auth: AUTH_BOUNDARY)
		do
			auth := a_auth
		end

feature -- Access

	auth: AUTH_BOUNDARY

feature -- Composition

	make_with_back (a_back: like back)
			-- <Precursor>; adopt element_envelope from back.
		do
			Precursor (a_back)
			if attached {RESTLY_WIRE_SCHEMA} a_back as l_schema then
				if element_envelope = Void then
					element_envelope := l_schema.element_envelope
				end
			end
		end

feature -- Commands (PRG)

	register (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- POST /users: create user, PRG to GET /users/{email}.
		local
			l_body: JSON_OBJECT
			l_id: STRING
		do
			l_body := parse_body (req)
			l_id := l_body.out
			if attached {RESTLY_POSTABLE [STRING, JSON_OBJECT]} back as l_store then
				l_store.extend_new (l_body, l_id)
				if l_store.extend_requests.has_key (l_id) then
					Result := {WSF_JSON_RESPONSE}.see_other
						.with_location (req.absolute_script_url (
							"/users/" + l_store.extend_requests [l_id]))
				else
					Result := {WSF_JSON_RESPONSE}.unprocessable_entity
				end
			else
				Result := {WSF_JSON_RESPONSE}.unprocessable_entity
			end
		end

	login (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- POST /users/login: authenticate, PRG to GET /users/{email}.
		local
			l_body: JSON_OBJECT
			l_email, l_password: STRING
		do
			l_body := parse_body (req)
			if
				attached {JSON_STRING} l_body ["email"] as l_e and then
				attached {JSON_STRING} l_body ["password"] as l_p
			then
				l_email := l_e.unescaped_string_8
				l_password := l_p.unescaped_string_8
				if
					attached {USER_STORE} back as l_users and then
					l_users.authenticate (l_email, l_password)
				then
					Result := {WSF_JSON_RESPONSE}.see_other
						.with_location (req.absolute_script_url (
							"/users/" + l_email))
				else
					Result := {WSF_JSON_RESPONSE}.unprocessable_entity
				end
			else
				Result := {WSF_JSON_RESPONSE}.unprocessable_entity
			end
		end

feature -- Queries

	user_by_id (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /users/{id}: PRG target for register and login.
		do
			if
				attached {WSF_STRING} req.path_parameter ("id") as l_id and then
				back.has_key (l_id.value.to_string_8)
			then
				Result := {WSF_JSON_RESPONSE}.ok.with_json_object (
					wrapped (back [l_id.value.to_string_8]))
			else
				Result := {WSF_JSON_RESPONSE}.not_found
			end
		end

	current_user (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- GET /user: return user identified by JWT.
		do
			if
				attached auth.subject_of (req) as l_email and then
				back.has_key (l_email)
			then
				Result := {WSF_JSON_RESPONSE}.ok.with_json_object (
					wrapped (back [l_email]))
			else
				Result := {WSF_JSON_RESPONSE}.unauthorized
			end
		end

	update_user (req: WSF_REQUEST): WSF_JSON_RESPONSE
			-- PUT /user: merge patch into user identified by JWT.
		do
			if
				attached auth.subject_of (req) as l_email and then
				back.has_key (l_email)
			then
				back.merge (parse_body (req), l_email)
				Result := {WSF_JSON_RESPONSE}.ok.with_json_object (
					wrapped (back [l_email]))
			else
				Result := {WSF_JSON_RESPONSE}.unauthorized
			end
		end

feature {NONE} -- Response

	wrapped (a_value: JSON_OBJECT): JSON_OBJECT
			-- <Precursor>: strip password_hash before wrapping.
		local
			l_clean: JSON_OBJECT
		do
			l_clean := a_value.twin
			l_clean.remove ("password_hash")
			Result := Precursor (l_clean)
		end

end
