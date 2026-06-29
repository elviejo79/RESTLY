note
	description: "Tests for chaining: hash1 <| hash2 <| hash3 <| hash_table"

class
	RESTLY_CHAIN_TEST

inherit
	EQA_TEST_SET
		redefine on_prepare end

feature {NONE} -- Setup

	hash1, hash2, hash3, hash_table: RESTLY_RESOURCE_BASIC_HASH [STRING, INTEGER]
	chain: RESTLY_COMBINATOR_CACHE_IDENTITY [STRING, INTEGER]

	on_prepare
		do
			create hash1.with_object_equality
			create hash2.with_object_equality
			create hash3.with_object_equality
			create hash_table.with_object_equality
			create chain.fronted_by (hash1)
			chain := chain <| hash2 <| hash3 <| hash_table
		end

feature -- Tests

	test_chain_extend_propagates_to_all
			-- Extending through the chain writes the value to every storage layer.
		do
			chain.extend (42, "x")
			assert ("hash1 has key", hash1.has_key ("x"))
			assert ("hash2 has key", hash2.has_key ("x"))
			assert ("hash3 has key", hash3.has_key ("x"))
			assert ("hash_table has key", hash_table.has_key ("x"))
			assert ("hash1 value", hash1.item ("x") = 42)
			assert ("hash_table value", hash_table.item ("x") = 42)
		end

	test_chain_miss_reads_from_hash_table
			-- A value stored only in hash_table is visible through the chain.
		do
			hash_table.extend (99, "y")
			assert ("chain sees key", chain.has_key ("y"))
			assert ("chain returns correct value", chain.item ("y") = 99)
		end

	test_chain_miss_populates_l1_cache
			-- After a cache miss, the L1 cache (hash1) is populated.
		do
			hash_table.extend (99, "y")
			assert ("not in hash1 before read", not hash1.has_key ("y"))
			assert ("chain reads ok", chain.item ("y") = 99)
			assert ("hash1 populated after miss", hash1.has_key ("y"))
		end

	test_chain_miss_populates_l2_caches
			-- After a cache miss, the intermediate caches (hash2, hash3) are also populated.
		do
			hash_table.extend (99, "y")
			assert ("chain reads ok", chain.item ("y") = 99)
			assert ("hash2 populated after miss", hash2.has_key ("y"))
			assert ("hash3 populated after miss", hash3.has_key ("y"))
		end

	test_chain_remove_propagates
			-- Removing through the chain clears the key from all layers.
		do
			chain.extend (7, "r")
			chain.remove ("r")
			assert ("chain no longer has key", not chain.has_key ("r"))
			assert ("hash_table cleared", not hash_table.has_key ("r"))
		end

end
