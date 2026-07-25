note
	description: "[
		M1 acceptance (design doc): principal equality first (ground
		rule 8), visibility is authorization, and denial as the
		inherited 404 precondition firing on the view's shrunken
		has_key — proven by assertion tags and by unchanged backing
		state, not by counting calls.
	]"
	testing: "covers/{AUTH_VIEW}, covers/{PRINCIPAL}"

class
	AUTH_VIEW_TEST_SET

inherit
	EQA_TEST_SET

feature {NONE} -- Fixtures

	alice: PRINCIPAL
		do
			create Result.make ("alice")
		end

	backing: RESOURCE_HASH_TABLE [STRING, STRING]
			-- One row for alice, one for bob.
		do
			create Result.make ("articles")
			Result.extend ("alice article", "alice/1")
			Result.extend ("bob article", "bob/1")
		end

	alice_capability: TEST_CAPABILITY
			-- Permits only alice's row.
		do
			create Result.make (alice)
			Result.permit ("alice/1")
		end

feature -- Tests: ground rule 8 first

	test_principal_equality_is_by_name
		local
			p, q, r: PRINCIPAL
		do
			create p.make ("alice")
			create q.make ("alice")
			create r.make ("bob")
			assert ("same_name_equal", p ~ q)
			assert ("same_name_same_hash", p.hash_code = q.hash_code)
			assert ("different_name_not_equal", not (p ~ r))
		end

feature -- Tests: visibility is authorization

	test_invisible_key_looks_absent
		local
			l_back: RESOURCE_HASH_TABLE [STRING, STRING]
			l_view: AUTH_VIEW [STRING, STRING]
		do
			l_back := backing
			create l_view.make (alice_capability, l_back)
			assert ("alice_sees_her_row", l_view.has_key ("alice/1"))
			assert ("item_reads_through", l_view ["alice/1"] ~ "alice article")
			assert ("bob_row_invisible", not l_view.has_key ("bob/1"))
			assert ("bob_row_exists_in_back", l_back.has_key ("bob/1"))
			assert ("alice_row_writable", l_view.writable ("alice/1"))
			assert ("bob_row_not_writable", not l_view.writable ("bob/1"))
			assert ("bob_row_not_removable", not l_view.removable ("bob/1"))
		end

	test_permitted_write_and_remove_reach_back
		local
			l_back: RESOURCE_HASH_TABLE [STRING, STRING]
			l_view: AUTH_VIEW [STRING, STRING]
		do
			l_back := backing
			create l_view.make (alice_capability, l_back)
			l_view.put ("edited", "alice/1")
			assert ("back_updated", l_back ["alice/1"] ~ "edited")
			l_view.remove ("alice/1")
			assert ("back_row_gone", not l_back.has_key ("alice/1"))
		end

feature -- Tests: denial is the inherited precondition

	test_item_on_invisible_key_fires_404_tag
		local
			l_view: AUTH_VIEW [STRING, STRING]
			l_value: STRING
			l_tag: detachable READABLE_STRING_32
			l_failed, l_retried: BOOLEAN
		do
			if l_failed then
				if attached l_tag as t then
					assert ("fired_error_404_not_found_got_" + t.out,
						t.same_string_general ("error_404_not_found"))
				else
					assert ("no_precondition_violation_captured", False)
				end
			else
				create l_view.make (alice_capability, backing)
				l_value := l_view ["bob/1"]
				l_value.do_nothing
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

	test_denied_remove_leaves_backing_row
		local
			l_back: detachable RESOURCE_HASH_TABLE [STRING, STRING]
			l_view: AUTH_VIEW [STRING, STRING]
			l_tag: detachable READABLE_STRING_32
			l_failed, l_retried: BOOLEAN
		do
			if l_failed then
				if attached l_tag as t then
					assert ("fired_has_key_got_" + t.out,
						t.same_string_general ("has_key"))
				else
					assert ("no_precondition_violation_captured", False)
				end
					-- Denial proven by unchanged state:
				assert ("bob_row_survives",
					attached l_back as b and then b.has_key ("bob/1"))
			else
				l_back := backing
				create l_view.make (alice_capability, l_back)
				l_view.remove ("bob/1")
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
