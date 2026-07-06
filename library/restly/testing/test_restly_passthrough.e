note
	description: "[
		Substitutability tests for RESTLY_PASSTHROUGH:
		the identity combinator inserts anywhere without
		observable change (Storage Combinators, Onward! '19).
	]"

class
	TEST_RESTLY_PASSTHROUGH

inherit
	EQA_TEST_SET

feature {NONE} -- Fixtures

	bare: RESTLY_HASH_TABLE [STRING, INTEGER]
		attribute create Result.with_object_equality end

	wrapped_ht: RESTLY_HASH_TABLE [STRING, INTEGER]
		attribute create Result.with_object_equality end

	wrapped: RESTLY_PASSTHROUGH [STRING, INTEGER]
		attribute create Result.make (wrapped_ht) end

feature -- Identity against a bare store

	test_identity_observable_equivalence
			-- Same verb sequence, same observations, bare vs wrapped.
		do
			bare.extend (1, "a")
			wrapped.extend (1, "a")
			assert ("has_key agrees", bare.has_key ("a") = wrapped.has_key ("a"))
			assert ("item agrees", bare ["a"] = wrapped ["a"])
			bare.put (2, "a")
			wrapped.put (2, "a")
			assert ("item agrees after put", bare ["a"] = wrapped ["a"])
			bare.force (3, "b")
			wrapped.force (3, "b")
			assert ("item agrees after force", bare ["b"] = wrapped ["b"])
			bare.remove ("a")
			wrapped.remove ("a")
			assert ("has_key agrees after remove", bare.has_key ("a") = wrapped.has_key ("a"))
			assert ("untouched key still agrees", bare ["b"] = wrapped ["b"])
		end

	test_writes_reach_backend
		do
			wrapped.extend (42, "k")
			assert ("backend has the write", wrapped_ht ["k"] = 42)
		end

feature -- Identity mid-chain

	test_insert_mid_chain_no_observable_change
			-- Cache scenario from TEST_RESTLY_CACHE step 2, with a
			-- passthrough spliced between cache and back.
		local
			plain_front, plain_back, spliced_front, spliced_back: RESTLY_HASH_TABLE [STRING, INTEGER]
			plain, spliced: RESTLY_CACHE [STRING, INTEGER]
		do
			create plain_front.with_object_equality
			create plain_back.with_object_equality
			create spliced_front.with_object_equality
			create spliced_back.with_object_equality
			create plain.make_with_back (plain_front, plain_back)
			create spliced.make_with_back (spliced_front,
				create {RESTLY_PASSTHROUGH [STRING, INTEGER]}.make (spliced_back))

			plain_back.extend (42, "k")
			spliced_back.extend (42, "k")
			assert ("has_key agrees", plain.has_key ("k") = spliced.has_key ("k"))
			assert ("item agrees", plain ["k"] = spliced ["k"])
			assert ("miss populates front in both",
				plain_front.has_key ("k") = spliced_front.has_key ("k"))

			plain.extend (7, "n")
			spliced.extend (7, "n")
			assert ("write-through crosses the passthrough", spliced_back ["n"] = 7)
			assert ("backs agree", plain_back ["n"] = spliced_back ["n"])

			plain.remove ("k")
			spliced.remove ("k")
			assert ("remove agrees", plain.has_key ("k") = spliced.has_key ("k"))
			assert ("gone behind the passthrough", not spliced_back.has_key ("k"))
		end

end
