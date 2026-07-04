note
	description: "[
		Tests for RESTLY_CACHE.
		Step 1: front-only cache.
		Step 2: two-level pipeline (front + back).
		Step 3: three-level pipeline built with <- chain operator.
	]"
	author: "agarciafdz@gmail.com"

class TEST_RESTLY_CACHE

inherit
	EQA_TEST_SET

feature {NONE} -- Fixtures

	front_ht: RESTLY_HASH_TABLE [STRING, INTEGER]
		attribute create Result.with_object_equality end

	back_ht: RESTLY_HASH_TABLE [STRING, INTEGER]
		attribute create Result.with_object_equality end

	middle_ht: RESTLY_HASH_TABLE [STRING, INTEGER]
		attribute create Result.with_object_equality end

	back2_ht: RESTLY_HASH_TABLE [STRING, INTEGER]
		attribute create Result.with_object_equality end

	cache: RESTLY_CACHE [STRING, INTEGER]
		attribute create Result.make (front_ht) end

	cache_with_back: RESTLY_CACHE [STRING, INTEGER]
		attribute create Result.make_with_back (front_ht, back_ht) end

	pipeline: RESTLY_CACHE [STRING, INTEGER]
		attribute
			Result := {RESTLY_CACHE [STRING, INTEGER]}.new_with_front (front_ht)
			          <| {RESTLY_CACHE [STRING, INTEGER]}.new_with_front (middle_ht)
			          <| {RESTLY_CACHE [STRING, INTEGER]}.new_with_front (back2_ht)
		end

feature -- Step 1: front-only

	test_s1_extend_then_item
		do
			cache.extend (42, "k")
			assert ("correct value after extend", cache ["k"] = 42)
		end

	test_s1_force_overwrites
		do
			cache.extend (1, "k")
			cache.force (42, "k")
			assert ("force overwrites existing key", cache ["k"] = 42)
		end

	test_s1_remove_deletes_key
		do
			cache.extend (1, "k")
			cache.remove ("k")
			assert ("key gone after remove", not cache.has_key ("k"))
		end

feature -- Step 2: two-level pipeline

	test_s2_has_key_in_back_only
		do
			back_ht.extend (1, "k")
			assert ("has_key true when key is only in back", cache_with_back.has_key ("k"))
		end

	test_s2_cache_miss_populates_front
		local
			v: INTEGER
		do
			back_ht.extend (42, "k")
			v := cache_with_back ["k"]
			assert ("miss populates front", front_ht.has_key ("k"))
			assert ("front has correct value", front_ht ["k"] = 42)
		end

	test_s2_warm_cache_serves_from_front
		local
			v: INTEGER
		do
			back_ht.extend (42, "k")
			v := cache_with_back ["k"]   -- miss: populates front
			back_ht.remove ("k")         -- clear back
			assert ("warm cache serves from front", cache_with_back ["k"] = 42)
		end

	test_s2_extend_writes_to_both
		do
			cache_with_back.extend (42, "k")
			assert ("extend: front correct", front_ht ["k"] = 42)
			assert ("extend: back correct", back_ht ["k"] = 42)
		end

	test_s2_remove_removes_from_both
		do
			front_ht.extend (42, "k")
			back_ht.extend (42, "k")
			cache_with_back.remove ("k")
			assert ("remove: gone from front", not front_ht.has_key ("k"))
			assert ("remove: gone from back", not back_ht.has_key ("k"))
		end

feature -- Step 3: three-level pipeline (front <- middle <- back)

	test_s3_l2_hit_populates_front_not_back
		local
			v: INTEGER
		do
			middle_ht.extend (42, "k")
			v := pipeline ["k"]
			assert ("L2 hit: front populated", front_ht ["k"] = 42)
			assert ("L2 hit: back2 untouched", not back2_ht.has_key ("k"))
		end

	test_s3_full_miss_populates_all_layers
		local
			v: INTEGER
		do
			back2_ht.extend (42, "k")
			v := pipeline ["k"]
			assert ("full miss: correct value", v = 42)
			assert ("full miss: middle populated", middle_ht ["k"] = 42)
			assert ("full miss: front populated", front_ht ["k"] = 42)
		end

	test_s3_extend_writes_to_all_layers
		do
			pipeline.extend (42, "k")
			assert ("extend: front correct", front_ht ["k"] = 42)
			assert ("extend: middle correct", middle_ht ["k"] = 42)
			assert ("extend: back correct", back2_ht ["k"] = 42)
		end

	test_s3_dash_alias_builds_pipeline
		local
			c: RESTLY_CACHE [STRING, INTEGER]
			fht, mht, bht: RESTLY_HASH_TABLE [STRING, INTEGER]
			p: RESTLY_CACHE [STRING, INTEGER]
			v: INTEGER
		do
			create c.make (front_ht)
			create fht.with_object_equality
			create mht.with_object_equality
			create bht.with_object_equality
			bht.extend (42, "k")
			p := (c - fht) <| (c - mht) <| (c - bht)
			v := p ["k"]
			assert ("dash alias: correct value from full miss", v = 42)
			assert ("dash alias: middle populated", mht.has_key ("k"))
			assert ("dash alias: front populated", fht.has_key ("k"))
		end

end -- class
