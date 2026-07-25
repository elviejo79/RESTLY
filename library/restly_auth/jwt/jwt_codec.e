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

	make (a_key: VERIFICATION_KEY; an_issuer, an_audience: READABLE_STRING_8)
		do
			key := a_key
			issuer := an_issuer.to_string_8
			audience := an_audience.to_string_8
		end

feature -- Access

	key: VERIFICATION_KEY

	issuer: STRING_8

	audience: STRING_8

feature -- Status report

	authenticated (a_raw: RAW_CREDENTIAL; a_time: DATE_TIME): BOOLEAN
			-- <Precursor>
		do
			Result := a_raw.is_present
				and then attached verified_token (a_raw, a_time) as t
				and then attached t.claimset.subjet
		end

feature -- Access

	mint (a_raw: RAW_CREDENTIAL; a_time: DATE_TIME): JWT_CAPABILITY
			-- <Precursor>
		local
			l_subject: PRINCIPAL
		do
			check
				established:
					attached verified_token (a_raw, a_time) as t
					and then attached t.claimset.subjet as s
			then
				create l_subject.make (s)
				create Result.make (l_subject, scopes_of (t))
			end
		end

feature {NONE} -- Implementation

	verified_token (a_raw: RAW_CREDENTIAL; a_time: DATE_TIME): detachable JWT
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
				attached l_loader.token (a_raw.text, l_loader.algorithms.hs256.name, key.secret, l_ctx) as t
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
