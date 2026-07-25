note
	description: "[
		The front desk for HS256 bearer tokens. `authenticated` is the
		doc's normative conjunction — present, well-formed, signature
		valid, nbf <= time <= exp, iss/aud match construction — whose
		implementation collapses to one JWT_LOADER.token call (M3,
		revised 2026-07-24). The JWT_CONTEXT always carries the request
		snapshot time: a Void time makes the loader read the live
		clock, violating ground rule 3.
	]"

class
	JWT_CODEC

inherit
	PRINCIPAL_CODEC [JWT_CAPABILITY]

create
	make

feature {NONE} -- Initialization

	make (a_secret, an_issuer, an_audience: READABLE_STRING_8)
		do
			secret := a_secret.to_string_8
			issuer := an_issuer.to_string_8
			audience := an_audience.to_string_8
		end

feature -- Access

	secret: STRING_8

	issuer: STRING_8

	audience: STRING_8

feature -- Status report

	authenticated (a_token: READABLE_STRING_8; a_time: DATE_TIME): BOOLEAN
			-- <Precursor>
		do
			Result := not a_token.is_empty
				and then attached verified_token (a_token, a_time) as t
				and then attached t.claimset.subjet
		end

	mint (a_token: READABLE_STRING_8; a_time: DATE_TIME): JWT_CAPABILITY
			-- <Precursor>
		do
			check
				established:
					attached verified_token (a_token, a_time) as t
					and then attached t.claimset.subjet as s
			then
				create Result.make (s, scopes_of (t))
			end
		end

feature {NONE} -- Implementation

	verified_token (a_token: READABLE_STRING_8; a_time: DATE_TIME): detachable JWT
			-- Signature-verified, claim-validated token, if any.
		local
			l_loader: JWT_LOADER
			l_ctx: JWT_CONTEXT
		do
			create l_loader
			create l_ctx
			l_ctx.set_time (a_time)
			l_ctx.set_issuer (issuer)
			l_ctx.set_audience (audience)
			if
				attached l_loader.token (a_token.to_string_8, l_loader.algorithms.hs256.name, secret, l_ctx) as t
				and then not t.has_error
			then
				Result := t
			end
		end

	scopes_of (t: JWT): LIST [READABLE_STRING_32]
			-- Space-separated `scope` claim, or nothing.
		do
			if attached t.claimset.string_32_claim ("scope") as s then
				Result := s.split (' ')
			else
				create {ARRAYED_LIST [READABLE_STRING_32]} Result.make (0)
			end
		end

end
