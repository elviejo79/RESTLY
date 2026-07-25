note
	description: "[
		M1b acceptance (design doc): alice's cursor yields only her
		keys; alice's wipe_out empties her world and leaves bob's rows
		in the backing table.
	]"
	testing: "covers/{LISTABLE_AUTH_VIEW}, covers/{AUTH_FILTER_CURSOR}"

class
	LISTABLE_AUTH_VIEW_TEST_SET

inherit
	EQA_TEST_SET

feature {NONE} -- Fixtures

	backing: RESOURCE_HASH_TABLE [STRING, STRING]
			-- Two rows for alice, one for bob.
		do
			create Result.make ("articles")
			Result.extend ("alice article", "alice/1")
			Result.extend ("alice draft", "alice/2")
			Result.extend ("bob article", "bob/1")
		end

	alice_capability: TEST_CAPABILITY
			-- Permits only alice's rows.
		do
			create Result.make ("alice")
			Result.permit ("alice/1")
			Result.permit ("alice/2")
		end

feature -- Tests

	test_cursor_yields_only_permitted_keys
		local
			l_view: LISTABLE_AUTH_VIEW [STRING, STRING]
			l_cursor: TABLE_ITERATION_CURSOR [STRING, STRING]
			l_keys: ARRAYED_LIST [STRING]
		do
			create l_view.make (alice_capability, backing)
			create l_keys.make (4)
			from
				l_cursor := l_view.new_cursor
			until
				l_cursor.after
			loop
				l_keys.extend (l_cursor.key)
				l_cursor.forth
			end
			assert ("two_keys_visible", l_keys.count = 2)
			l_keys.compare_objects
			assert ("alice_1_listed", l_keys.has ("alice/1"))
			assert ("alice_2_listed", l_keys.has ("alice/2"))
			assert ("bob_1_not_listed", not l_keys.has ("bob/1"))
		end

	test_wipe_out_spares_invisible_rows
		local
			l_back: RESOURCE_HASH_TABLE [STRING, STRING]
			l_view: LISTABLE_AUTH_VIEW [STRING, STRING]
		do
			l_back := backing
			create l_view.make (alice_capability, l_back)
			l_view.wipe_out
			assert ("alice_world_empty", l_view.new_cursor.after)
			assert ("alice_1_gone_from_back", not l_back.has_key ("alice/1"))
			assert ("alice_2_gone_from_back", not l_back.has_key ("alice/2"))
			assert ("bob_row_survives", l_back.has_key ("bob/1"))
		end

end
