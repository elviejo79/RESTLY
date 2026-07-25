note
	description: "[
		M4 acceptance: memoization (same principal twice, same view
		object), evict (next `view` call builds a fresh one), and two
		principals whose visible key sets differ per their capabilities.
	]"
	testing: "covers/{SESSION_SWITCH}"

class
	SESSION_SWITCH_TEST_SET

inherit
	EQA_TEST_SET

feature {NONE} -- Fixtures

	backing: RESOURCE_HASH_TABLE [STRING, STRING]
		do
			create Result.make ("articles")
			Result.extend ("alice article", "alice/1")
			Result.extend ("bob article", "bob/1")
		end

	capability_for (a_name: STRING; a_key: STRING): TEST_CAPABILITY
		do
			create Result.make (create {PRINCIPAL}.make (a_name))
			Result.permit (a_key)
		end

feature -- Tests

	test_same_principal_twice_yields_same_view_object
		local
			l_switch: SESSION_SWITCH [STRING, STRING]
			l_first, l_second: AUTH_VIEW [STRING, STRING]
		do
			create l_switch.make (backing)
			l_first := l_switch.view (capability_for ("alice", "alice/1"))
			l_second := l_switch.view (capability_for ("alice", "alice/1"))
			assert ("memoized", l_first = l_second)
		end

	test_evict_makes_next_view_fresh
		local
			l_switch: SESSION_SWITCH [STRING, STRING]
			l_first, l_second: AUTH_VIEW [STRING, STRING]
		do
			create l_switch.make (backing)
			l_first := l_switch.view (capability_for ("alice", "alice/1"))
			l_switch.evict (create {PRINCIPAL}.make ("alice"))
			l_second := l_switch.view (capability_for ("alice", "alice/1"))
			assert ("fresh_after_evict", l_first /= l_second)
		end

	test_two_principals_see_different_key_sets
		local
			l_switch: SESSION_SWITCH [STRING, STRING]
			l_alice, l_bob: AUTH_VIEW [STRING, STRING]
		do
			create l_switch.make (backing)
			l_alice := l_switch.view (capability_for ("alice", "alice/1"))
			l_bob := l_switch.view (capability_for ("bob", "bob/1"))
			assert ("different_views", l_alice /= l_bob)
			assert ("alice_sees_hers", l_alice.has_key ("alice/1"))
			assert ("alice_blind_to_bobs", not l_alice.has_key ("bob/1"))
			assert ("bob_sees_his", l_bob.has_key ("bob/1"))
			assert ("bob_blind_to_alices", not l_bob.has_key ("alice/1"))
		end

end
