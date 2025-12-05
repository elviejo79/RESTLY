note
	description: "Test suite for PICO_CACHE class"
	author: "HTTPico Team"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TEST_PICO_CACHE

inherit
	EQA_TEST_SET

feature -- PICO_CACHE Tests

	test_cache_miss_fetches_and_stores
			-- Test that cache miss fetches from destination and stores in source
		local
			cache: PICO_CACHE [STRING,STRING]
			cache_source, cache_dest: FILE_SCHEME
			test_content, retrieved: STRING
			test_key: PATH_HTTPICO
		do
			create cache_source.make (file_path)
			create cache_dest.make (file_path)
			create cache.make (cache_source, cache_dest)
			test_content := "Content from destination"
			create test_key.make_from_string ("cache_test_1.txt")

				-- Put data only in destination
			cache_dest.force (test_content, test_key)

				-- First access should fetch from destination
			retrieved := cache [test_key]
			assert ("Should retrieve correct content", retrieved ~ test_content)

				-- Verify it's now in source (cache)
			assert ("Source should have key after cache miss", cache_source.has_key (test_key))
			assert ("Source should have correct content", cache_source [test_key] ~ test_content)

				-- Cleanup
			cache.remove (test_key)
		end

	test_cache_hit_serves_from_source
			-- Test that cache hit serves from source without hitting destination
		local
			cache: PICO_CACHE [STRING, STRING]
			cache_source, cache_dest: FILE_SCHEME
			source_content, dest_content, retrieved: STRING
			test_key: PATH_HTTPICO
		do
			create cache_source.make (cache_source_path)
			create cache_dest.make (cache_dest_path)
			create cache.make (cache_source, cache_dest)
			source_content := "Cached content"
			dest_content := "Destination content"
			create test_key.make_from_string ("cache_test_2.txt")

				-- Put different data in source and destination
			cache_source.force (source_content, test_key)
			cache_dest.force (dest_content, test_key)

				-- Access should return from source (cache)
			retrieved := cache [test_key]
			assert ("Should retrieve from cache (source)", retrieved ~ source_content)
			assert ("Should not retrieve from destination", retrieved /~ dest_content)

				-- Cleanup
			cache.remove (test_key)
		end

	test_force_updates_both_storages
			-- Test that force writes to both source and destination
		local
			cache: PICO_CACHE [STRING, STRING]
			cache_source, cache_dest: FILE_SCHEME
			test_content: STRING
			test_key: PATH_HTTPICO
		do
			create cache_source.make (file_path)
			create cache_dest.make (file_path)
			create cache.make (cache_source, cache_dest)
			test_content := "Write-through content"
			create test_key.make_from_string ("cache_test_3.txt")

				-- Force through cache
			cache.force (test_content, test_key)

				-- Verify in both storages
			assert ("Destination should have key", cache_dest.has_key (test_key))
			assert ("Source should have key", cache_source.has_key (test_key))
			assert ("Destination should have correct content", cache_dest [test_key] ~ test_content)
			assert ("Source should have correct content", cache_source [test_key] ~ test_content)
			assert ("Last inserted key should be set", cache.last_inserted_key ~ test_key)

				-- Cleanup
			cache.remove (test_key)
		end

	test_collection_extend_caches_result
			-- Test that collection_extend writes to destination and caches result
		local
			cache: PICO_CACHE [STRING, STRING]
			cache_source, cache_dest: FILE_SCHEME
			test_content: STRING
			inserted_key: PATH_HTTPICO
		do
			create cache_source.make (file_path)
			create cache_dest.make (file_path)
			create cache.make (cache_source, cache_dest)
			test_content := "Collection extend content"

				-- Extend collection
			cache.collection_extend (test_content)

				-- Get the key that was inserted
			inserted_key := cache.last_inserted_key

				-- Verify in both storages
			assert ("Destination should have key", cache_dest.has_key (inserted_key))
			assert ("Source should have key", cache_source.has_key (inserted_key))
			assert ("Destination should have correct content", cache_dest [inserted_key] ~ test_content)
			assert ("Source should have correct content", cache_source [inserted_key] ~ test_content)

				-- Cleanup
			cache.remove (inserted_key)
		end

	test_remove_when_only_in_destination
			-- Test that remove works when key only exists in destination
		local
			cache: PICO_CACHE [STRING, STRING]
			cache_source, cache_dest: FILE_SCHEME
			test_content: STRING
			test_key: PATH_HTTPICO
		do
			create cache_source.make (file_path)
			create cache_dest.make (file_path)
			create cache.make (cache_source, cache_dest)
			test_content := "Only in destination"
			create test_key.make_from_string ("cache_test_4.txt")

				-- Put only in destination
			cache_dest.force (test_content, test_key)

				-- Remove through cache
			cache.remove (test_key)

				-- Verify removed from destination
			assert ("Destination should not have key", not cache_dest.has_key (test_key))
			assert ("Source should not have key", not cache_source.has_key (test_key))
		end

	test_cache_coherence_after_force
			-- Test that cache updates when force is called with new value
		local
			cache: PICO_CACHE [STRING, STRING]
			cache_source, cache_dest: FILE_SCHEME
			old_content, new_content, retrieved: STRING
			test_key: PATH_HTTPICO
		do
			create cache_source.make (file_path)
			create cache_dest.make (file_path)
			create cache.make (cache_source, cache_dest)
			old_content := "Old cached content"
			new_content := "New updated content"
			create test_key.make_from_string ("cache_test_5.txt")

				-- Initial force
			cache.force (old_content, test_key)
			assert ("Should have old content", cache [test_key] ~ old_content)

				-- Update with new content
			cache.force (new_content, test_key)

				-- Verify cache updated
			retrieved := cache [test_key]
			assert ("Cache should have new content", retrieved ~ new_content)
			assert ("Cache should not have old content", retrieved /~ old_content)

				-- Cleanup
			cache.remove (test_key)
		end

-- NOTE: This test is disabled because PICO_CACHE currently requires both frontend and backend to use the same type.
	-- To enable this test, we need to make FILE_SCHEME generic or create a conversion-aware PICO_CACHE variant.
	--test_file_cache_with_todobackend
	--		-- Test PICO_CACHE with FILE_SCHEME as source and TODOBACKEND_API as destination
	--	local
	--		cache: PICO_CACHE [TODO_ITEM, STRING]
	--		file_source: FILE_SCHEME
	--		http_dest: TODOBACKEND_API
	--		test_todo, retrieved: TODO_ITEM
	--		test_key: PATH_HTTPICO
	--		test_uri: URI
	--	do
	--		-- Setup
	--		create file_source.make (file_path)
	--		create test_uri.make_from_string ("http://localhost:8080/items/")
	--		create http_dest.make (test_uri)

	--		create cache.make (file_source, http_dest)

	--		-- Create test TODO_ITEM
	--		create test_todo.make_empty
	--		test_todo.put (create {JSON_STRING}.make_from_string ("Test todo from cache"), "text")
	--		test_todo.put (create {JSON_BOOLEAN}.make_boolean (false), "completed")

	--		-- Test collection_extend (POST)
	--		cache.collection_extend (test_todo)
	--		test_key := cache.last_inserted_key

	--		-- Verify the item was added to both source and destination
	--		assert ("Destination should have key", http_dest.has_key (test_key))
	--		assert ("Source should have key", file_source.has_key (test_key))

	--		-- Test cache hit - should serve from file_source
	--		retrieved := cache [test_key]
	--		assert ("Should retrieve from cache", retrieved.is_equal (test_todo))

	--		-- Cleanup
	--		cache.remove (test_key)
	--		assert ("Should be removed from both", not file_source.has_key (test_key) and not http_dest.has_key (test_key))
	--	end

feature -- Test values

	file_path: FILE_URL
		attribute
			create Result.make_from_string ("file:///home/agarciafdz/exp_resources")
		end

	cache_source_path: FILE_URL
		attribute
			create Result.make_from_string ("file:///home/agarciafdz/exp_resources/cache_source")
		end

	cache_dest_path: FILE_URL
		attribute
			create Result.make_from_string ("file:///home/agarciafdz/exp_resources/cache_dest")
		end

end
