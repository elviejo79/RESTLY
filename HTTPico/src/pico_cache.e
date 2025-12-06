note
	description: "[
		{PICO_CACHE_CONVERTIBLE}.
		A caching implementation for heterogeneous storage where the representation
		type R differs from the storage type S.

		Uses CONVERTIBLE_TO interface to convert R to S for frontend storage,
		while maintaining a transparent R interface to the user.

		Example: Cache TODO_ITEM (R) in FILE_SCHEME (stores STRING = S)
		while backend TODOBACKEND_API uses TODO_ITEM directly.
	]"
	author: "Alejandro Garcia"
	date: "$Date$"
	revision: "$Revision$"

class
	PICO_CACHE [R -> CONVERTIBLE_TO[S] create make_from_s end, S -> attached ANY]

inherit
	PICO_REQUEST_METHODS [R]

create
	make

feature {NONE} -- Initialization

	make (a_cache: PICO_SCHEME_HANDLER[S]; a_dest: PICO_SCHEME_HANDLER[R])
			-- Initialize with cache storage (stores S) and destination (stores R)
      require
         cache_and_server_must_be_different: not (a_cache ~ a_dest)  and then not (a_cache.base_uri ~ a_dest.base_uri)
		do
			frontend := a_cache
			backend := a_dest
		ensure
			frontend_set: frontend = a_cache
			backend_set: backend = a_dest
		end

feature {NONE} -- Access

	frontend: PICO_SCHEME_HANDLER[S]
			-- The cache storage (stores STRING values)

	backend: PICO_SCHEME_HANDLER[R]
			-- The destination storage (stores R values)

feature -- Queries (cache-aside pattern)

	has_key (key: PATH_PICO): BOOLEAN
			-- Check if key exists in source (cache) or destination
		do
			Result := frontend.has_key (key) or else backend.has_key (key)
		end

	item alias "[]" (key: PATH_PICO): R
			-- Retrieve item from cache if available, otherwise fetch from destination
		local
			frontend_data: S
		do
			if frontend.has_key (key) then
				-- Cache hit: get S from frontend, convert to R
				frontend_data := frontend [key]
				create Result.make_from_s (frontend_data)
			else
				-- Cache miss: fetch R directly from backend
				Result := backend [key]
				-- Store in frontend as S (using convertible_to_s conversion)
				frontend.force (Result.to_s, key)
			end
		end

feature -- Commands (write-through pattern)

	force (data: R; key: PATH_PICO)
			-- Write to both destination and source (cache)
		do
			-- Write to backend (destination) - backend expects R
			backend.force (data, key)

			-- Write to frontend (cache) - convert R to S
			frontend.force (data.to_s, key)

			-- Track insertion
			last_inserted_key := key
		end

	collection_extend (data: R)
			-- Add to destination and cache the result
		do
			-- Add to backend - backend expects R
			backend.collection_extend (data)

			check attached backend.last_inserted_key as backend_key then
				-- Cache in frontend - convert R to S
				frontend.force (data.to_s, backend_key)
				-- Track insertion
				last_inserted_key := backend_key
			end
		end

	remove (key: PATH_PICO)
			-- Remove from both destination and source (cache)
		do
			-- Remove from destination
			backend.remove (key)

			-- Remove from cache (if exists)
			if frontend.has_key (key) then
				frontend.remove (key)
			end
		end

feature -- Attributes

	last_inserted_key: PATH_PICO
			-- Track last insertion
		attribute
			create Result.make_from_string ("")
		end

end
