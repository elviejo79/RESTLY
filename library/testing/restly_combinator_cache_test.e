note
	description: "Tests for RESTLY_COMBINATOR_CACHE using two RESTLY_RESOURCE_BASIC_HASHes as frontend and backend."

class
	RESTLY_COMBINATOR_CACHE_TEST

inherit
	EQA_TEST_SET
		redefine on_prepare end

feature {NONE} -- Setup

	frontend: RESTLY_RESOURCE_BASIC_HASH[STRING, INTEGER]
	backend: RESTLY_RESOURCE_BASIC_HASH[STRING, INTEGER]
	cache: RESTLY_COMBINATOR_CACHE_IDENTITY[STRING, INTEGER]

	on_prepare
		do
			create frontend.with_object_equality
			create backend.with_object_equality
			create cache.make (frontend, backend)
		end

feature -- Tests

	test_extend_writes_to_both
		do
			cache.extend (42, "x")
			assert ("frontend has key", frontend.has_key ("x"))
			assert ("backend has key", backend.has_key ("x"))
			assert ("frontend value correct", frontend.item ("x") = 42)
			assert ("backend value correct", backend.item ("x") = 42)
		end

	test_cache_hit_reads_from_frontend
		do
			frontend.extend (7, "k")
			assert ("cache hit returns value", cache.item ("k") = 7)
		end

	test_cache_miss_populates_frontend
		do
			backend.extend (99, "m")
			assert ("frontend does not have key before miss", not frontend.has_key ("m"))
			assert ("cache miss returns correct value", cache.item ("m") = 99)
			assert ("frontend populated after miss", frontend.has_key ("m"))
		end

	test_has_key_checks_both
		do
			cache.extend (1, "cached")
			backend.extend (2, "b")
			assert ("cached key visible", cache.has_key ("cached"))
			assert ("backend-only key visible", cache.has_key ("b"))
			assert ("absent key not found", not cache.has_key ("z"))
		end

	test_remove_removes_from_both
		do
			cache.extend (5, "r")
			cache.remove ("r")
			assert ("frontend no longer has key", not frontend.has_key ("r"))
			assert ("backend no longer has key", not backend.has_key ("r"))
		end

	test_count_reflects_backend
		do
			assert ("starts empty", cache.count = 0)
			cache.extend (1, "a")
			cache.extend (2, "b")
			assert ("count is 2", cache.count = 2)
		end

	test_wipe_out_clears_both
		do
			cache.extend (1, "a")
			cache.extend (2, "b")
			cache.wipe_out
			assert ("frontend empty", frontend.count = 0)
			assert ("backend empty", backend.count = 0)
		end

end
