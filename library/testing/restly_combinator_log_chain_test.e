note
	description: "Tests for RESTLY_COMBINATOR_LOG embedded in a cache chain"

class
	RESTLY_COMBINATOR_LOG_CHAIN_TEST

inherit
	EQA_TEST_SET
		redefine on_prepare end

feature {NONE} -- Setup

	front, hash2, hash3, hash1, hash_log: RESTLY_RESOURCE_BASIC_HASH [STRING, INTEGER]
	log_layer: RESTLY_COMBINATOR_LOG [STRING, INTEGER]
	chain: RESTLY_COMBINATOR_CACHE_IDENTITY [STRING, INTEGER]

	on_prepare
			-- chain: front -> hash3 -> hash2 -> log_layer -> hash1
		do
			create front.with_object_equality
			create hash3.with_object_equality
			create hash2.with_object_equality
			create hash1.with_object_equality
			create hash_log.with_object_equality
			create log_layer.fronted_by (hash_log)
			create chain.fronted_by (front)
			chain := chain <| hash3 <| hash2 <| log_layer <| hash1
		end

feature -- Tests

	test_log_records_read_miss
			-- A cache miss that reaches the log layer is recorded.
		local
			v: INTEGER
		do
			hash1.extend (99, "x")
			v := chain.item ("x")
			assert ("value correct", v = 99)
			assert ("log has one entry", log_layer.entries.count = 1)
			assert ("op is item", log_layer.entries.first.op ~ "item")
		end

	test_log_records_write_through
			-- An extend propagates through the whole chain and is recorded.
		do
			chain.extend (42, "y")
			assert ("one log entry", log_layer.entries.count = 1)
			assert ("op is extend", log_layer.entries.last.op ~ "extend")
			assert ("hash1 received value", hash1.has_key ("y"))
		end

	test_second_read_hits_l1_cache_not_log
			-- After a cache miss, subsequent reads come from the L1 cache and
			-- do not reach the log layer.
		local
			v: INTEGER
		do
			hash1.extend (99, "x")
			v := chain.item ("x")
			v := chain.item ("x")
			assert ("log called only once", log_layer.entries.count = 1)
			assert ("value still correct", v = 99)
		end

	test_log_ticks_increase_over_chain_operations
		local
			v: INTEGER
		do
			hash1.extend (1, "a")
			hash1.extend (2, "b")
			chain.extend (3, "c")
			v := chain.item ("a")
			v := chain.item ("b")
			assert ("three log entries", log_layer.entries.count = 3)
			assert ("ticks are monotonic", log_layer.entries.last.tick > log_layer.entries.first.tick)
		end

	test_log_as_front_anti_pattern
			-- log_layer <| hash3 <| hash2 <| hash1 creates nested LOG wrappers and
			-- leaves spare_log pointing at a stale intermediate object.  Operations
			-- go to bad_chain's entries, not spare_log's.  This test fails to document
			-- the trap: use create log.make (hash_log, cache_chain) instead.
		local
			bad_chain: RESTLY_COMBINATOR_LOG [STRING, INTEGER]
			spare_log: RESTLY_COMBINATOR_LOG [STRING, INTEGER]
		do
			create spare_log.fronted_by (hash_log)
			bad_chain := spare_log <| hash3 <| hash2 <| hash1
			bad_chain.extend (42, "x")
			assert ("log_layer captures operations (fails: stale reference)", spare_log.entries.count >= 1)
		end

end
