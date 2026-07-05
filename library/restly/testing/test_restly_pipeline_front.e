note
	description: "Tests for RESTLY_PIPELINE_FRONT via SAMPLE_FRONT."

class
	TEST_RESTLY_PIPELINE_FRONT

inherit
	EQA_TEST_SET

feature {NONE} -- Fixtures

	inner: RESTLY_HASH_TABLE [INTEGER, SAMPLE_ITEM]
		attribute create Result.with_object_equality end

	front: SAMPLE_FRONT
		attribute create Result.make (inner, create {SAMPLE_KEY_CONVERTER}, create {SAMPLE_VALUE_CONVERTER}) end

feature -- Tests

	test_extend_and_item_with_conversion
			-- Extend via STRING key/value; inner gets INTEGER/SAMPLE_ITEM.
		do
			front.extend ("hello", "1")
			assert ("front has key", front.has_key ("1"))
			assert ("front value", front ["1"] ~ "hello")
			assert ("inner has integer key", inner.has_key (1))
			assert ("inner value", inner.item (1).title ~ "hello")
		end

	test_has_key_converts
			-- has_key converts STRING to INTEGER before lookup.
		do
			inner.extend (create {SAMPLE_ITEM}.make ("direct"), 5)
			assert ("front sees it", front.has_key ("5"))
			assert ("front does not see absent", not front.has_key ("99"))
		end

	test_remove_with_conversion
			-- remove converts the key and removes from inner.
		do
			inner.extend (create {SAMPLE_ITEM}.make ("bye"), 7)
			front.remove ("7")
			assert ("gone from inner", not inner.has_key (7))
			assert ("gone from front", not front.has_key ("7"))
		end

	test_force_with_conversion
			-- force converts and upserts.
		do
			front.extend ("first", "3")
			front.force ("second", "3")
			assert ("updated", front ["3"] ~ "second")
			assert ("inner updated", inner.item (3).title ~ "second")
		end

	test_put_with_conversion
			-- put converts and updates existing.
		do
			front.extend ("original", "4")
			front.put ("modified", "4")
			assert ("updated via front", front ["4"] ~ "modified")
			assert ("inner updated", inner.item (4).title ~ "modified")
		end

	test_new_cursor_wraps_inner
			-- Iteration on the front exposes STRING keys and converted values.
		local
			l_cursor: V_MAP_ITERATOR [STRING, STRING]
			l_found_1, l_found_2: BOOLEAN
		do
			inner.extend (create {SAMPLE_ITEM}.make ("aaa"), 1)
			inner.extend (create {SAMPLE_ITEM}.make ("bbb"), 2)
			from
				l_cursor := front.new_cursor
			until
				l_cursor.after
			loop
				if l_cursor.key ~ "1" and l_cursor.item ~ "aaa" then
					l_found_1 := True
				end
				if l_cursor.key ~ "2" and l_cursor.item ~ "bbb" then
					l_found_2 := True
				end
				l_cursor.forth
			end
			assert ("found key 1", l_found_1)
			assert ("found key 2", l_found_2)
		end

	test_count_delegates
			-- count reflects inner storage count.
		do
			assert ("empty", front.count = 0)
			inner.extend (create {SAMPLE_ITEM}.make ("x"), 1)
			assert ("one", front.count = 1)
		end

	test_wipe_out_delegates
			-- wipe_out clears the inner storage.
		do
			inner.extend (create {SAMPLE_ITEM}.make ("x"), 1)
			inner.extend (create {SAMPLE_ITEM}.make ("y"), 2)
			front.wipe_out
			assert ("inner empty", inner.count = 0)
			assert ("front empty", front.count = 0)
		end

	test_merge_updates_partial
			-- merge updates the item in place via the front.
		do
			front.extend ("original", "1")
			front.merge ("patched", "1")
			assert ("patched via front", front ["1"] ~ "patched")
			assert ("patched in inner", inner.item (1).title ~ "patched")
		end

	test_backed_by_swaps_inner
			-- <| replaces the inner storage and returns the front for chaining.
		local
			l_other: RESTLY_HASH_TABLE [INTEGER, SAMPLE_ITEM]
			l_result: SAMPLE_FRONT
		do
			front.extend ("in_original", "1")
			create l_other.with_object_equality
			l_other.extend (create {SAMPLE_ITEM}.make ("in_other"), 2)
			l_result := front <| l_other
			assert ("returns current", l_result = front)
			assert ("sees new inner", front.has_key ("2"))
			assert ("value from new inner", front ["2"] ~ "in_other")
			assert ("old key gone", not front.has_key ("1"))
		end

end
