note
	description: "[
		{PICO_CACHE}.
		A caching implementation that provides transparent caching between
		a fast local source (cache) and a slower destination (backing store).

		Implements cache-aside pattern for reads and write-through for writes.
	]"
	author: "Alejandro Garcia"
	date: "$Date$"
	revision: "$Revision$"

class
	PICO_CACHE [R -> attached ANY]

inherit
	INTERMEDIARY [R,R]

create
	make


feature -- Queries (cache-aside pattern)

	has_key (key: PATH_HTTPICO): BOOLEAN
			-- Check if key exists in source (cache) or destination
		do
			Result := frontend.has_key (key) or else backend.has_key (key)
		end

	item alias "[]" (key: PATH_HTTPICO): R
			-- Retrieve item from cache if available, otherwise fetch from destination
		do
			if frontend.has_key (key) then
				-- Cache hit
				Result := frontend [key]
			else
				-- Cache miss - fetch from destination and cache it
				Result := backend [key]
				frontend.force (Result, key)
			end
		end

feature -- Commands (write-through pattern)

	force (data: R; key: PATH_HTTPICO)
			-- Write to both destination and source (cache)
		do
			-- Write to destination first (backing store)
			backend.force (data, key)

			-- Then update cache
			frontend.force (data, key)

			-- Track insertion
			last_inserted_key := key
		end

	collection_extend (data: R)
			-- Add to destination and cache the result
		do
			-- Add to backend storage
			backend.collection_extend (data)

			check attached backend.last_inserted_key as backend_key then
				frontend.force (data, backend_key)
				-- Track insertion
				last_inserted_key := backend_key
			end
		end

	remove (key: PATH_HTTPICO)
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

	last_inserted_key: PATH_HTTPICO
			-- Track last insertion
		attribute
			create Result.make_from_string ("")
		end

end
