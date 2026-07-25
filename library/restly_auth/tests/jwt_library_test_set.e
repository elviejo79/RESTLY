note
	description: "[
		M2 acceptance (revised 2026-07-24): certifies our configuration
		of the distribution jwt library, not code of ours. Every
		JWT_CONTEXT sets `time` explicitly — a Void time makes the
		loader read the live clock, violating ground rule 3.
	]"
	testing: "covers/{JWT_LOADER}"

class
	JWT_LIBRARY_TEST_SET

inherit
	EQA_TEST_SET

feature {NONE} -- Fixtures

	secret: STRING = "restly-test-secret"

	issuer: STRING = "restly-issuer"

	audience: STRING = "restly-audience"

	entry_epoch: INTEGER = 1784000000
			-- Fixed request-entry snapshot (seconds since epoch).

	entry_time: DATE_TIME
		do
			create Result.make_from_epoch (entry_epoch)
		end

	signed_token: STRING
			-- Hand-built HS256 token: sub alice, our iss/aud,
			-- exp one hour after entry, nbf one hour before.
		local
			l_jws: JWS
		do
			create l_jws
			l_jws.claimset.set_subject ({STRING_32} "alice")
			l_jws.claimset.set_issuer (issuer)
			l_jws.claimset.set_audience (audience)
			l_jws.claimset.set_expiration_time (create {DATE_TIME}.make_from_epoch (entry_epoch + 3600))
			l_jws.claimset.set_not_before_time (create {DATE_TIME}.make_from_epoch (entry_epoch - 3600))
			Result := l_jws.encoded_string (secret)
		end

	context: JWT_CONTEXT
			-- Validation context with the snapshot time — never Void.
		do
			create Result
			Result.set_time (entry_time)
			Result.set_issuer (issuer)
			Result.set_audience (audience)
		end

feature -- Tests

	test_hs256_round_trip
		local
			l_loader: JWT_LOADER
		do
			create l_loader
			if attached l_loader.token (signed_token, l_loader.algorithms.hs256.name, secret, context) as t then
				assert ("verifies", not t.has_error)
				assert ("subject_survives",
					attached t.claimset.subjet as s and then s.same_string_general ("alice"))
			else
				assert ("token_parsed", False)
			end
		end

	test_tampered_signature_rejected
		local
			l_loader: JWT_LOADER
			l_token: STRING
		do
			create l_loader
			l_token := signed_token
			if l_token [l_token.count] = 'x' then
				l_token [l_token.count] := 'y'
			else
				l_token [l_token.count] := 'x'
			end
			if attached l_loader.token (l_token, l_loader.algorithms.hs256.name, secret, context) as t then
				assert ("tampering_detected", t.has_error)
			else
				assert ("token_parsed", False)
			end
		end

	test_rfc_7515_a1_example_verifies
			-- RFC 7515 Appendix A.1: token and key are the published
			-- vectors; context time is before the vector's exp.
		local
			l_loader: JWT_LOADER
			l_key: STRING
			l_ctx: JWT_CONTEXT
		do
			create l_loader
			l_key := l_loader.base64url_decode ("AyM1SysPpbyDfgZld3umj1qzKObwVMkoqQ-EstJQLr_T-1qS0gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr1Z9CAow")
			create l_ctx
			l_ctx.set_time (create {DATE_TIME}.make_from_epoch (1300000000))
			l_ctx.set_issuer ("joe")
			if attached l_loader.token ("eyJ0eXAiOiJKV1QiLA0KICJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQogImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ.dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk",
				l_loader.algorithms.hs256.name, l_key, l_ctx) as t
			then
				assert ("rfc_vector_verifies", not t.has_error)
			else
				assert ("token_parsed", False)
			end
		end

end
