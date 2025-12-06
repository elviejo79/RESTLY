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

	cache: PICO_CACHE [STRING_CONVERTIBLE, STRING]
			-- Shared cache instance for tests

	cache_storage: FILE_SCHEME[STRING]
			-- Frontend cache storage

	server: FILE_SCHEME[STRING_CONVERTIBLE]
			-- Backend server storage

	test_keys: LINKED_LIST [PATH_PICO]
			-- List of keys created during tests for cleanup

	key_counter: INTEGER
			-- Counter for generating unique test keys

	on_prepare
			-- Set up shared test infrastructure
		do
			create cache_storage.make (cache_path)
			create server.make (server_path)
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

	make_unique_key: PATH_PICO
			-- Generate a unique test key and track it for cleanup
		do
			key_counter := key_counter + 1
			create Result.make_from_string ("cache_test_" + key_counter.out + ".txt")
			test_keys.extend (Result)
		end

feature {NONE} -- Test Helpers for STRING_CONVERTIBLE cache

	assert_string_cache_miss_behavior (test_data: STRING_CONVERTIBLE; test_key: PATH_PICO)
			-- Helper to verify cache miss behavior for STRING_CONVERTIBLE cache
		local
			retrieved: STRING_CONVERTIBLE
		do
			server.force (test_data, test_key)
			retrieved := cache [test_key]
			assert ("Cache miss: should retrieve correct content", retrieved ~ test_data)
			assert ("Cache miss: frontend should have key after fetch", cache_storage.has_key (test_key))
			assert ("Cache miss: frontend should have correct content", cache_storage [test_key] ~ test_data.to_s)
		end

	assert_string_cache_hit_behavior (cached_data: STRING_CONVERTIBLE; backend_data: STRING_CONVERTIBLE; test_key: PATH_PICO)
			-- Helper to verify cache hit behavior for STRING_CONVERTIBLE cache
		local
			retrieved: STRING_CONVERTIBLE
		do
			cache_storage.force (cached_data.to_s, test_key)
			server.force (backend_data, test_key)
			retrieved := cache [test_key]
			assert ("Cache hit: should retrieve from frontend", retrieved ~ cached_data)
			assert ("Cache hit: should not retrieve from backend", retrieved /~ backend_data)
		end

	assert_string_collection_extend_behavior (test_data: STRING_CONVERTIBLE): PATH_PICO
			-- Helper to verify collection_extend behavior for STRING_CONVERTIBLE cache
		do
			cache.collection_extend (test_data)
			check attached cache.last_inserted_key as key then
				Result := key
				assert ("Collection extend: backend should have correct content", server [Result] ~ test_data)
				assert ("Collection extend: frontend should have correct content", cache_storage [Result] ~ test_data.to_s)
			end
		end

feature {NONE} -- Test Helpers for TODO_ITEM cache with external instances

	assert_todo_collection_extend_behavior (
			a_cache: PICO_CACHE [TODO_ITEM, STRING];
			a_backend: PICO_REQUEST_METHODS [TODO_ITEM];
			a_frontend: PICO_REQUEST_METHODS [STRING];
			test_data: TODO_ITEM): PATH_PICO
			-- Helper to verify collection_extend behavior for TODO_ITEM cache
			-- This helper needs explicit cache/backend/frontend parameters because
			-- test_file_cache_with_todobackend uses different types than the default
		local
			backend_item: TODO_ITEM
		do
			a_cache.collection_extend (test_data)
			check attached a_cache.last_inserted_key as key then
				Result := key
				-- Backend may add extra fields (id, url, order), so check key fields exist
				backend_item := a_backend [Result]
				assert ("Collection extend: backend should have key", a_backend.has_key (Result))
				assert ("Collection extend: backend should have title", backend_item.has_key ("title"))
				assert ("Collection extend: backend should have completed", backend_item.has_key ("completed"))
				assert ("Collection extend: frontend should have correct content", a_frontend [Result] ~ test_data.to_s)
			end
		end

feature -- PICO_CACHE Tests

	test_cache_miss_fetches_and_stores
			-- Test that cache miss fetches from server and stores in cache
		local
			test_content: STRING_CONVERTIBLE
			test_key: PATH_PICO
		do
			create test_content.make_from_string ("Content from server")
			test_key := make_unique_key

			assert_string_cache_miss_behavior (test_content, test_key)
		end

	test_cache_hit_serves_from_cache
			-- Test that cache hit serves from cache without hitting server
		local
			cached_content, server_content: STRING_CONVERTIBLE
			test_key: PATH_PICO
		do
			create cached_content.make_from_string ("Cached content")
			create server_content.make_from_string ("Server content")
			test_key := make_unique_key

			assert_string_cache_hit_behavior (cached_content, server_content, test_key)
		end

	test_collection_extend_caches_result
			-- Test that collection_extend writes to server and caches result
		local
			test_content: STRING_CONVERTIBLE
			inserted_key: PATH_PICO
		do
			create test_content.make_from_string ("Collection extend content")

			inserted_key := assert_string_collection_extend_behavior (test_content)
			test_keys.extend (inserted_key)
		end

	test_cache_coherence_after_force
			-- Test that cache updates when force is called with new value
		local
			old_content, new_content, retrieved: STRING_CONVERTIBLE
			test_key: PATH_PICO
		do
			create old_content.make_from_string ("Old cached content")
			create new_content.make_from_string ("New updated content")
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
			-- Test PICO_CACHE with TODO_ITEM: FILE_SCHEME frontend + TODOBACKEND_API backend
		local
			cached_backend: PICO_CACHE [TODO_ITEM, STRING]
			file_frontend: FILE_SCHEME[STRING]
			http_backend: TODOBACKEND_API
			test_todo, modified_cache_todo: TODO_ITEM
			test_key: PATH_PICO
			retrieved: TODO_ITEM
		do
			-- Setup - this test needs its own cache instance due to type conversion
			create file_frontend.make (file_path)
			create http_backend.make_default
			create cached_backend.make (file_frontend, http_backend)

			-- Create test TODO_ITEM
			create test_todo.make_empty
			test_todo.put (create {JSON_STRING}.make_from_string ("Test todo from cache"), "title")
			test_todo.put (create {JSON_BOOLEAN}.make_boolean (false), "completed")

			-- Test 1: collection_extend behavior
			test_key := assert_todo_collection_extend_behavior (cached_backend, http_backend, file_frontend, test_todo)

			-- Test 2: cache hit behavior
			-- Modify the frontend cache to have different data than backend
			create modified_cache_todo.make_empty
			modified_cache_todo.put (create {JSON_STRING}.make_from_string ("Modified cached todo"), "title")
			modified_cache_todo.put (create {JSON_BOOLEAN}.make_boolean (true), "completed")

			-- Directly modify only the frontend (simulating stale cache)
			file_frontend.force (modified_cache_todo.to_s, test_key)

			-- Retrieve should come from cache (modified version), not backend (original)
			retrieved := cached_backend [test_key]
			assert ("Cache hit: should retrieve modified version from frontend",
					retrieved.is_equal (modified_cache_todo))
			assert ("Cache hit: should not retrieve original from backend",
					not retrieved.is_equal (test_todo))

			-- Cleanup
			cached_backend.remove (test_key)
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

