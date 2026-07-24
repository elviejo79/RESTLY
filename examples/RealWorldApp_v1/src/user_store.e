note
	description: "[
		User store: hash table keyed by email.
		Registration = extend_new: mints the key from the body's
		email field, hashes the password before storing.
		Every read mints a fresh JWT so the token is always current.
		Stripping password_hash is the response layer's job.
	]"

class
	USER_STORE

inherit
	RESOURCE_HASH_TABLE [STRING, JSON_OBJECT]
		redefine
			make,
			item
		end

	RESTLY_POSTABLE [STRING, JSON_OBJECT]
		redefine
			extend_new
		end

	RESTLY_PATCHABLE [STRING, JSON_OBJECT]

	RESTLY_WIRE_SCHEMA

create
	make

feature {NONE} -- Initialization

	make (a_name: STRING)
			-- <Precursor>; declares the RealWorld wire schema.
		do
			Precursor (a_name)
			element_envelope := "user"
		end

feature -- Access

	secret: STRING assign set_secret
			-- HS256 signing secret; set by the execution at wiring time.
		attribute
			create Result.make_empty
		end

	set_secret (a_secret: STRING)
		do
			secret := a_secret
		end

feature -- REST verbs

	item alias "[]" (k: STRING): JSON_OBJECT assign force
			-- <Precursor>: mints a fresh JWT on every read.
		local
			l_result: JSON_OBJECT
		do
			l_result := Precursor (k).deep_twin
			l_result.replace (create {JSON_STRING}.make_from_string (mint_token (k)), "token")
			Result := l_result
		end

feature -- Extension

	extend_new (a_v: JSON_OBJECT; a_request_id: HASHABLE)
			-- <Precursor>: registration. Hashes the password, builds
			-- the stored user object, then delegates to the inherited
			-- extend_new for key minting and storage.
		local
			l_user: JSON_OBJECT
		do
			if not extend_requests.has_key (a_request_id) then
				create l_user.make_with_capacity (6)
				if attached {JSON_STRING} a_v ["email"] as l then
					l_user.put (l, "email")
				end
				if attached {JSON_STRING} a_v ["username"] as l then
					l_user.put (l, "username")
				end
				if attached {JSON_STRING} a_v ["password"] as l_pw then
					l_user.put (create {JSON_STRING}.make_from_string (
						hash_password (l_pw.unescaped_string_8)), "password_hash")
				end
				l_user.put (create {JSON_NULL}, "bio")
				l_user.put (create {JSON_NULL}, "image")
				l_user.put (create {JSON_STRING}.make_from_string (""), "token")
				Precursor (l_user, a_request_id)
			end
		end

feature {NONE} -- Key minting

	fresh_key (a_v: JSON_OBJECT): STRING
			-- <Precursor>: the email from the registration body.
		do
			if attached {JSON_STRING} a_v ["email"] as l_email then
				Result := l_email.unescaped_string_8
			else
				Result := "unknown"
			end
		end

feature -- Queries

	authenticate (a_email, a_password: STRING): BOOLEAN
			-- Does `a_email` exist with a matching password?
		do
			if has_key (a_email) then
				if attached {JSON_STRING} table [a_email] ["password_hash"] as l_hash then
					Result := l_hash.unescaped_string_8.same_string (hash_password (a_password))
				end
			end
		end

feature {NONE} -- Implementation

	hash_password (a_password: READABLE_STRING_8): STRING
			-- ponytail: hash_code for dev; bcrypt if auth matters
		do
			Result := a_password.hash_code.out
		end

	mint_token (a_email: READABLE_STRING_8): STRING
			-- JWT with sub=email, signed with `secret`.
		local
			l_jws: JWS
		do
			create l_jws.make_with_json_payload ("{%"sub%":%"" + a_email + "%"}")
			l_jws.set_algorithm_to_hs256
			Result := l_jws.encoded_string (secret)
		end

end
