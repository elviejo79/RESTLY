note
	description: "Tests for RESTLY_POSTABLE via SAMPLE_FRONT."

class
	TEST_RESTLY_POSTABLE

inherit
	EQA_TEST_SET

feature {NONE} -- Fixtures

	inner: RESTLY_HASH_TABLE [INTEGER, SAMPLE_ITEM]
		attribute create Result.with_object_equality end

	front: SAMPLE_FRONT
		attribute create Result.make (inner, create {SAMPLE_KEY_CONVERTER}, create {SAMPLE_VALUE_CONVERTER}) end

feature -- Tests

	test_extend_new_stores_value
			-- After extend_new, the key is present and the value matches.
		local
			l_key: STRING
		do
			front.extend_new ("alpha", "req-1")
			l_key := front.extend_requests [{STRING} "req-1"]
			assert ("key present", front.has_key (l_key))
			assert ("value matches", front [l_key] ~ "alpha")
		end

	test_auto_increment_produces_distinct_keys
			-- Two extend_new calls produce two distinct, increasing keys.
		local
			k1, k2: STRING
		do
			front.extend_new ("first", "req-1")
			front.extend_new ("second", "req-2")
			k1 := front.extend_requests [{STRING} "req-1"]
			k2 := front.extend_requests [{STRING} "req-2"]
			assert ("distinct keys", not (k1 ~ k2))
			assert ("increasing", k2.to_integer > k1.to_integer)
		end

	test_distinct_request_ids_map_to_own_keys
			-- Each request_id maps to its own unique key.
		local
			k1, k2: STRING
		do
			front.extend_new ("a", "id-a")
			front.extend_new ("b", "id-b")
			k1 := front.extend_requests [{STRING} "id-a"]
			k2 := front.extend_requests [{STRING} "id-b"]
			assert ("id-a has key", front.has_key (k1))
			assert ("id-b has key", front.has_key (k2))
			assert ("different keys", not (k1 ~ k2))
		end

	test_idempotency
			-- Duplicate request_id with same value is a no-op.
		local
			l_key: STRING
			l_count: INTEGER
		do
			front.extend_new ("alpha", "req-1")
			l_key := front.extend_requests [{STRING} "req-1"]
			l_count := front.count
			front.extend_new ("alpha", "req-1")
			assert ("same key", front.extend_requests [{STRING} "req-1"] ~ l_key)
			assert ("count unchanged", front.count = l_count)
			assert ("value intact", front [l_key] ~ "alpha")
		end

	test_retry_after_other_traffic
			-- Retry does not consume the auto-increment sequence.
		local
			k1, k2, k3: STRING
		do
			front.extend_new ("a", "id-1")
			k1 := front.extend_requests [{STRING} "id-1"]
			front.extend_new ("b", "id-2")
			k2 := front.extend_requests [{STRING} "id-2"]
			front.extend_new ("a", "id-1")
			k3 := front.extend_requests [{STRING} "id-1"]
			assert ("retry returns original key", k1 ~ k3)
			assert ("next fresh insert gets expected key", k2.to_integer = k1.to_integer + 1)
		end

end
