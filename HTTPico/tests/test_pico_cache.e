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
		redefine
			on_prepare,
			on_clean
		end

feature {NONE} -- Test Infrastructure

	cache: PICO_CACHE [STRING]
			-- Shared cache instance for tests

	cache_storage: FILE_SCHEME
			-- Frontend cache storage

	server: FILE_SCHEME
			-- Backend server storage

	test_keys: LINKED_LIST [PATH_HTTPICO]
			-- List of keys created during tests for cleanup

	key_counter: INTEGER
			-- Counter for generating unique test keys

	on_prepare
			-- Set up shared test infrastructure
		do
			create cache_storage.make (file_path)
			create server.make (file_path)
			create cache.make (cache_storage, server)
			create test_keys.make
			key_counter := 0
		end

	on_clean
			-- Clean up all test keys
		do
			across test_keys as k loop
				if cache.has_key (k.item) then
					cache.remove (k.item)
				end
			end
		end

	make_unique_key: PATH_HTTPICO
			-- Generate a unique test key and track it for cleanup
		do
			key_counter := key_counter + 1
			create Result.make_from_string ("cache_test_" + key_counter.out + ".txt")
			test_keys.extend (Result)
		end

feature -- PICO_CACHE Tests

	test_cache_miss_fetches_and_stores
			-- Test that cache miss fetches from server and stores in cache
		local
			test_content, retrieved: STRING
			test_key: PATH_HTTPICO
		do
			test_content := "Content from server"
			test_key := make_unique_key

				-- Put data only in server
			server.force (test_content, test_key)

				-- First access should fetch from server
			retrieved := cache [test_key]
			assert ("Should retrieve correct content", retrieved ~ test_content)

				-- Verify it's now in cache
			assert ("Cache should have key after cache miss", cache_storage.has_key (test_key))
			assert ("Cache should have correct content", cache_storage [test_key] ~ test_content)
		end

	test_cache_hit_serves_from_cache
			-- Test that cache hit serves from cache without hitting server
		local
			local_cache: PICO_CACHE [STRING]
			local_cache_storage, local_server: FILE_SCHEME
			cached_content, server_content, retrieved: STRING
			test_key: PATH_HTTPICO
		do
			-- This test needs separate paths to verify cache hit behavior
			create local_cache_storage.make (cache_path)
			create local_server.make (server_path)
			create local_cache.make (local_cache_storage, local_server)
			cached_content := "Cached content"
			server_content := "Server content"
			create test_key.make_from_string ("cache_test_2.txt")

				-- Put different data in cache and server
			local_cache_storage.force (cached_content, test_key)
			local_server.force (server_content, test_key)

				-- Access should return from cache
			retrieved := local_cache [test_key]
			assert ("Should retrieve from cache", retrieved ~ cached_content)
			assert ("Should not retrieve from server", retrieved /~ server_content)

				-- Cleanup
			local_cache.remove (test_key)
		end

	test_collection_extend_caches_result
			-- Test that collection_extend writes to server and caches result
		local
			test_content: STRING
			inserted_key: PATH_HTTPICO
		do
			test_content := "Collection extend content"

				-- Extend collection
			cache.collection_extend (test_content)

				-- Get the key that was inserted
			inserted_key := cache.last_inserted_key
			test_keys.extend (inserted_key)

				-- Verify content is correct in both storages
			assert ("Server should have correct content", server [inserted_key] ~ test_content)
			assert ("Cache should have correct content", cache_storage [inserted_key] ~ test_content)
		end

	test_cache_coherence_after_force
			-- Test that cache updates when force is called with new value
		local
			old_content, new_content, retrieved: STRING
			test_key: PATH_HTTPICO
		do
			old_content := "Old cached content"
			new_content := "New updated content"
			test_key := make_unique_key

				-- Initial force
			cache.force (old_content, test_key)
			assert ("Should have old content", cache [test_key] ~ old_content)

				-- Update with new content
			cache.force (new_content, test_key)

				-- Verify cache updated
			retrieved := cache [test_key]
			assert ("Cache should have new content", retrieved ~ new_content)
			assert ("Cache should not have old content", retrieved /~ old_content)
		end

	test_file_cache_with_todobackend
			-- Test PICO_CACHE_CONVERTIBLE with FILE_SCHEME as frontend cache and TODOBACKEND_API as backend server
		local
			convertible_cache: PICO_CACHE_CONVERTIBLE [TODO_ITEM, STRING]
			file_frontend: FILE_SCHEME
			http_backend: TODOBACKEND_API
			test_todo, retrieved: TODO_ITEM
			test_key: PATH_HTTPICO
		do
			-- Setup - this test needs its own cache instance due to type conversion
			create file_frontend.make (file_path)
			create http_backend.make_default
			create convertible_cache.make (file_frontend, http_backend)

			-- Create test TODO_ITEM
			create test_todo.make_empty
			test_todo.put (create {JSON_STRING}.make_from_string ("Test todo from cache"), "title")
			test_todo.put (create {JSON_BOOLEAN}.make_boolean (false), "completed")

			-- Test collection_extend (POST)
			convertible_cache.collection_extend (test_todo)
			test_key := convertible_cache.last_inserted_key

			-- Verify the item was added to both frontend and backend
			assert ("Backend should have key", http_backend.has_key (test_key))
			assert ("Frontend should have key", file_frontend.has_key (test_key))

			-- Test cache hit - should serve from file_frontend (converted back to TODO_ITEM)
			retrieved := convertible_cache [test_key]
			assert ("Should retrieve from cache", retrieved.is_equal (test_todo))

			-- Cleanup
			convertible_cache.remove (test_key)
				-- Postcondition ensures: not has_key(key)
		end

feature -- Test values

	file_path: FILE_URL
		attribute
			create Result.make_from_string ("file:///home/agarciafdz/exp_resources")
		end

	cache_path: FILE_URL
		attribute
			create Result.make_from_string ("file:///home/agarciafdz/exp_resources/cache")
		end

	server_path: FILE_URL
		attribute
			create Result.make_from_string ("file:///home/agarciafdz/exp_resources/server")
		end

end

