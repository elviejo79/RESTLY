note
	description: "[
		{PICO_CACHE}.
		A caching implementation for heterogeneous storage where the cache (frontend)
		stores rich domain objects (R) and the persistent backend stores serialized
		form (S).

		Uses PICO_MAPPER to handle bidirectional R ↔ S conversion.
		Optimized for performance: cache hits have zero conversion overhead.

		Example: Cache TODO_ITEM (R) in PICO_TABLE (fast, in-memory)
		         Persist JSON_VALUE/STRING (S) in FILE_SCHEME (slow, disk)
	]"
	author: "Alejandro Garcia"
	date: "$Date$"
	revision: "$Revision$"

class
	PICO_CACHE [R -> attached ANY, S -> attached ANY]

inherit
	PICO_REQUEST_METHODS [R]

create
	make

feature {NONE} -- Initialization

	make (a_fast_cache: PICO_REQUEST_METHODS[R]; a_slow_backend: PICO_REQUEST_METHODS[S]; a_mapper: PICO_MAPPER[R, S])
			-- Initialize with fast cache (stores R), slow backend (stores S), and mapper
		require
			cache_and_backend_must_be_different: not (a_fast_cache ~ a_slow_backend)
		do
			frontend := a_fast_cache
			backend := a_slow_backend
			mapper := a_mapper

		end

feature {NONE} -- Access

	frontend: PICO_REQUEST_METHODS[R]
			-- The fast cache storage (stores rich domain objects R)

	backend: PICO_REQUEST_METHODS[S]
			-- The slow persistent storage (stores serialized form S)

	mapper: PICO_MAPPER[R, S]
			-- Bidirectional mapper between R and S

feature -- Queries (cache-aside pattern)

	has_key (key: PATH_PICO): BOOLEAN
			-- Check if key exists in source (cache) or destination
		do
			Result := frontend.has_key (key) or else backend.has_key (key)
		end

	item alias "[]" (key: PATH_PICO): R
			-- Retrieve item from cache if available, otherwise fetch from backend
			-- Optimized: cache hits have zero conversion overhead
		local
			backend_data: S
		do
			if frontend.has_key (key) then
				-- Cache HIT: Return R directly from frontend (no conversion!)
				Result := frontend [key]
			else
				-- Cache MISS: Fetch S from backend, convert to R, cache it
				backend_data := backend [key]
				Result := mapper.representation (backend_data)
				-- Store rich object R in frontend cache
				frontend.force (Result, key)
			end
		end

feature -- Commands (write-through pattern)

	force (data: R; key: PATH_PICO)
			-- Write to both cache and backend (write-through)
		do
			-- Write to frontend cache - store rich object R directly
			frontend.force (data, key)

			-- Write to backend - convert R to S for persistence
			backend.force (mapper.to_store (data), key)

			-- Track insertion
			last_inserted_key := key
		end

	collection_extend (data: R)
			-- Add to backend and cache the result (write-through)
		do
			-- Add to frontend first - it generates the key
			frontend.collection_extend (data)

			check attached frontend.last_inserted_key as frontend_key then
				-- Persist to backend using the same key
				backend.force (mapper.to_store (data), frontend_key)
				-- Track insertion
				last_inserted_key := frontend_key
			end
		end

	remove (key: PATH_PICO)
			-- Remove from both cache and backend
		do
			-- Remove from frontend cache (if exists)
			if frontend.has_key (key) then
				frontend.remove (key)
			end

			-- Remove from backend persistent storage
			if backend.has_key (key) then
				backend.remove (key)
			end
		end

	wipe_out
			-- Remove all items from both cache and backend
		local
			keys_to_remove: ARRAYED_LIST [PATH_PICO]
		do
			-- Clear frontend cache (if it has wipe_out)
			if attached {HASH_TABLE [R, PATH_PICO]} frontend as ht then
				ht.wipe_out
			end

			-- Clear backend (iterate through its keys)
			create keys_to_remove.make (10)
			across backend.all_keys as key_cursor loop
				keys_to_remove.extend (key_cursor.item)
			end
			across keys_to_remove as key_cursor loop
				backend.remove (key_cursor.item)
			end
		end

feature -- Queries

	all_keys: ITERABLE [PATH_PICO]
			-- All keys from both frontend cache and backend storage
		local
			combined_keys: ARRAYED_SET [PATH_PICO]
		do
			create combined_keys.make (10)

			-- Add keys from frontend cache
			across frontend.all_keys as key_cursor loop
				combined_keys.put (key_cursor.item)
			end

			-- Add keys from backend storage
			across backend.all_keys as key_cursor loop
				combined_keys.put (key_cursor.item)
			end

			Result := combined_keys
		end

feature -- Attributes

	last_inserted_key: PATH_PICO
			-- last inserted key is empty on creation
		attribute
			create Result.make_from_string ("")
		end

end
