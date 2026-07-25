note
	description: "[
		M3 acceptance: the 9-row behavioral table (TEST_CLOCK, real
		stores) plus the two contract-violation tests — thesis evidence
		that the contracts are live.
	]"
	testing: "covers/{JWT_CODEC}, covers/{JWT_CAPABILITY}"

class
	JWT_CODEC_TEST_SET

inherit
	EQA_TEST_SET

feature {NONE} -- Fixtures

	secret: STRING = "restly-test-secret"

	issuer: STRING = "restly-issuer"

	audience: STRING = "restly-audience"

	entry_epoch: INTEGER = 1784000000
			-- The request-entry snapshot, as seconds since epoch.

	entry_time: DATE_TIME
		do
			create Result.make_from_epoch (entry_epoch)
		end

	codec: JWT_CODEC
		do
			create Result.make (create {VERIFICATION_KEY}.make (secret), issuer, audience)
		end

	backing: RESOURCE_HASH_TABLE [STRING, STRING]
		do
			create Result.make ("articles")
			Result.extend ("alice article", "alice/1")
		end

	raw (a_text: STRING): RAW_CREDENTIAL
		do
			create Result.make (a_text)
		end

	token_with (a_scope: STRING; an_exp_epoch, a_nbf_epoch: INTEGER; an_aud, a_secret: STRING): STRING
			-- Hand-built HS256 token for subject alice.
		local
			l_jws: JWS
		do
			create l_jws
			l_jws.claimset.set_subject ({STRING_32} "alice")
			l_jws.claimset.set_issuer (issuer)
			l_jws.claimset.set_audience (an_aud)
			l_jws.claimset.set_claim ("scope", a_scope)
			l_jws.claimset.set_expiration_time (create {DATE_TIME}.make_from_epoch (an_exp_epoch))
			l_jws.claimset.set_not_before_time (create {DATE_TIME}.make_from_epoch (a_nbf_epoch))
			Result := l_jws.encoded_string (a_secret)
		end

	good_token (a_scope: STRING): STRING
			-- Valid token: exp one hour after entry, nbf one hour before.
		do
			Result := token_with (a_scope, entry_epoch + 3600, entry_epoch - 3600, audience, secret)
		end

feature -- Tests: behavioral table rows 1-6 (not authenticated)

	test_row_1_absent_credential
		do
			assert ("not_authenticated",
				not codec.authenticated (create {RAW_CREDENTIAL}.make_absent, entry_time))
		end

	test_row_2_garbage_string
		do
			assert ("not_authenticated",
				not codec.authenticated (raw ("this-is-not-a-jwt"), entry_time))
		end

	test_row_3_valid_claims_wrong_key
		do
			assert ("not_authenticated", not codec.authenticated (
				raw (token_with ("read write delete", entry_epoch + 3600, entry_epoch - 3600, audience, "some-other-secret")),
				entry_time))
		end

	test_row_4_expired
		do
			assert ("not_authenticated", not codec.authenticated (
				raw (token_with ("read", entry_epoch - 100, entry_epoch - 3600, audience, secret)),
				entry_time))
		end

	test_row_5_not_yet_valid
		do
			assert ("not_authenticated", not codec.authenticated (
				raw (token_with ("read", entry_epoch + 3600, entry_epoch + 100, audience, secret)),
				entry_time))
		end

	test_row_6_wrong_audience
		do
			assert ("not_authenticated", not codec.authenticated (
				raw (token_with ("read", entry_epoch + 3600, entry_epoch - 3600, "someone-else", secret)),
				entry_time))
		end

feature -- Tests: behavioral table rows 7-9

	test_row_7_read_only_scope
		local
			l_raw: RAW_CREDENTIAL
			l_back: RESOURCE_HASH_TABLE [STRING, STRING]
			l_view: AUTH_VIEW [STRING, STRING]
		do
			l_raw := raw (good_token ("read"))
			assert ("authenticated", codec.authenticated (l_raw, entry_time))
			l_back := backing
			create l_view.make (codec.mint (l_raw, entry_time), l_back)
			assert ("row_visible", l_view.has_key ("alice/1"))
			assert ("not_writable", not l_view.writable ("alice/1"))
				-- The gateway's write path: pre-check said no, so the
				-- verb is never called; denial proven by unchanged state.
			if l_view.writable ("alice/1") then
				l_view.put ("edited", "alice/1")
			end
			assert ("backing_unchanged", l_back ["alice/1"] ~ "alice article")
		end

	test_row_8_full_scope
		local
			l_raw: RAW_CREDENTIAL
			l_back: RESOURCE_HASH_TABLE [STRING, STRING]
			l_view: AUTH_VIEW [STRING, STRING]
		do
			l_raw := raw (good_token ("read write delete"))
			assert ("authenticated", codec.authenticated (l_raw, entry_time))
			l_back := backing
			create l_view.make (codec.mint (l_raw, entry_time), l_back)
			assert ("writable", l_view.writable ("alice/1"))
			l_view.put ("edited", "alice/1")
			assert ("backing_changed", l_back ["alice/1"] ~ "edited")
			assert ("removable", l_view.removable ("alice/1"))
			l_view.remove ("alice/1")
			assert ("backing_row_gone", not l_back.has_key ("alice/1"))
		end

	test_row_9_expiry_mid_request_still_succeeds
			-- Pins Idea 4: the clock is read ONCE, at request entry, and
			-- that snapshot governs every expiry decision in the request.
			-- The token expires between the entry snapshot and a later
			-- TEST_CLOCK advance, yet the request still succeeds: a
			-- ticket is checked when you walk in, nobody drags you out
			-- of the theater mid-movie. `is_valid` deliberately never
			-- checks expiry (ground rule 4), so nothing here can notice
			-- the wall clock moving. This test exists so no future
			-- "improvement" quietly re-checks expiry mid-request.
		local
			l_clock: TEST_CLOCK
			l_snapshot: DATE_TIME
			l_raw: RAW_CREDENTIAL
			l_cap: JWT_CAPABILITY
			l_back: RESOURCE_HASH_TABLE [STRING, STRING]
			l_view: AUTH_VIEW [STRING, STRING]
		do
			create l_clock.make
			l_clock.now := entry_time
			l_snapshot := l_clock.now
				-- Token expires 50 seconds after entry.
			l_raw := raw (token_with ("read write delete", entry_epoch + 50, entry_epoch - 3600, audience, secret))
			assert ("authenticated_at_entry", codec.authenticated (l_raw, l_snapshot))
			l_cap := codec.mint (l_raw, l_snapshot)
				-- Wall clock advances past exp while the request runs.
			l_clock.now := create {DATE_TIME}.make_from_epoch (entry_epoch + 100)
				-- The request continues on its entry snapshot: still succeeds.
			assert ("capability_still_valid", l_cap.is_valid)
			l_back := backing
			create l_view.make (l_cap, l_back)
			l_view.put ("written after wall-clock expiry", "alice/1")
			assert ("write_succeeded", l_back ["alice/1"] ~ "written after wall-clock expiry")
		end

feature -- Tests: the contracts are live

	test_mint_unauthenticated_fires_established
		local
			l_cap: detachable JWT_CAPABILITY
			l_tag: detachable READABLE_STRING_32
			l_failed, l_retried: BOOLEAN
		do
			if l_failed then
				if attached l_tag as t then
					assert ("fired_established_got_" + t.out, t.same_string_general ("established"))
				else
					assert ("no_precondition_violation_captured", False)
				end
			else
				l_cap := codec.mint (raw ("this-is-not-a-jwt"), entry_time)
				assert ("precondition_should_have_fired", False)
			end
		rescue
			if not l_retried then
				if attached (create {EXCEPTION_MANAGER_FACTORY}).exception_manager.last_exception as e
					and then attached {PRECONDITION_VIOLATION} e.original as pv
				then
					l_tag := pv.description
				end
				l_failed := True
				l_retried := True
				retry
			end
		end

	test_view_with_invalidated_capability_fires_capability_valid
		local
			l_cap: TEST_CAPABILITY
			l_view: detachable AUTH_VIEW [STRING, STRING]
			l_tag: detachable READABLE_STRING_32
			l_failed, l_retried: BOOLEAN
		do
			if l_failed then
				if attached l_tag as t then
					assert ("fired_capability_valid_got_" + t.out, t.same_string_general ("capability_valid"))
				else
					assert ("no_precondition_violation_captured", False)
				end
			else
				create l_cap.make (create {PRINCIPAL}.make ("mallory"))
				l_cap.invalidate
				create l_view.make (l_cap, backing)
				assert ("precondition_should_have_fired", False)
			end
		rescue
			if not l_retried then
				if attached (create {EXCEPTION_MANAGER_FACTORY}).exception_manager.last_exception as e
					and then attached {PRECONDITION_VIOLATION} e.original as pv
				then
					l_tag := pv.description
				end
				l_failed := True
				l_retried := True
				retry
			end
		end

end
