note
	description: "Tests for RESTLY_LISTABLE via RESTLY_HASH_TABLE."

class
	TEST_RESTLY_LISTABLE

inherit
	EQA_TEST_SET

feature {NONE} -- Fixtures

	table: RESTLY_HASH_TABLE [STRING, INTEGER]
		attribute create Result.with_object_equality end

feature -- Tests

	test_iteration_yields_inserted_items
			-- Iteration yields exactly the inserted items.
		local
			l_cursor: TABLE_ITERATION_CURSOR [INTEGER, STRING]
			l_count: INTEGER
		do
			table.extend (10, "a")
			table.extend (20, "b")
			table.extend (30, "c")
			from
				l_cursor := table.new_cursor
			until
				l_cursor.after
			loop
				l_count := l_count + 1
				l_cursor.forth
			end
			assert ("count matches", l_count = 3)
			assert ("table count", table.count = 3)
		end

	test_iteration_exposes_keys
			-- For every cursor position, key and item form a valid pair.
		local
			l_cursor: TABLE_ITERATION_CURSOR [INTEGER, STRING]
			l_found_a, l_found_b: BOOLEAN
		do
			table.extend (10, "a")
			table.extend (20, "b")
			from
				l_cursor := table.new_cursor
			until
				l_cursor.after
			loop
				if l_cursor.key ~ "a" and l_cursor.item = 10 then
					l_found_a := True
				end
				if l_cursor.key ~ "b" and l_cursor.item = 20 then
					l_found_b := True
				end
				l_cursor.forth
			end
			assert ("found a", l_found_a)
			assert ("found b", l_found_b)
		end

	test_wipe_out_clears_table
			-- After wipe_out, has_key is false and iteration yields nothing.
		local
			l_cursor: TABLE_ITERATION_CURSOR [INTEGER, STRING]
		do
			table.extend (1, "x")
			table.extend (2, "y")
			table.wipe_out
			assert ("x gone", not table.has_key ("x"))
			assert ("y gone", not table.has_key ("y"))
			assert ("count zero", table.count = 0)
			l_cursor := table.new_cursor
			assert ("iteration empty", l_cursor.after)
		end

	test_wipe_out_on_empty_is_legal
			-- wipe_out on an empty table does not raise.
		do
			table.wipe_out
			assert ("still empty", table.count = 0)
		end

end
