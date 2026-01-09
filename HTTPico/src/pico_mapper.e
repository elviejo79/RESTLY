note
	description: "[
		{PICO_MAPPER}.
		A mapper that acts as a facade for PICO_REQUEST_METHODS[S] storage
		while exposing a PICO_REQUEST_METHODS[R] interface.

		Converts between representation type R and storage type S using:
		* to_store: R -> S (for storing data)
		* representation: S -> R (for retrieving data)

		By default uses PICO_TABLE[S] as storage backend.
		Storage can be customized using set_store.
	]"
	author: "Alejandro Garcia"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	PICO_MAPPER [R -> attached ANY, S -> attached ANY]

inherit
	PICO_REQUEST_METHODS [R]

feature {NONE} -- Initialization

	make
			-- Initialize with default PICO_TABLE storage
		do
			create {PICO_TABLE [S]} storage.make (10)
		ensure
			storage_set: attached storage
		end

feature {NONE} -- Implementation

	storage: PICO_REQUEST_METHODS [S]
			-- Internal storage working with type S

feature -- Configuration

	set_store (s: PICO_REQUEST_METHODS [S])
			-- Set custom storage backend
		do
			storage := s
		ensure
			storage_set: storage = s
		end

feature -- Conversion (deferred)

	to_store (r: R): S
			-- Convert from exposed type R to storage type S
		deferred
		end

	representation (s: S): R
			-- Convert from storage type S to exposed type R
		deferred
		end

feature -- Queries (delegated with conversion)

	has_key (key: PATH_PICO): BOOLEAN
			-- Equivalent to http HEAD
		do
			Result := storage.has_key (key)
		end

	item alias "[]" (key: PATH_PICO): R
			-- Equivalent to http GET
		do
			Result := representation (storage.item (key))
		end

feature -- Commands (delegated with conversion)

	collection_extend (data: R)
			-- Equivalent to http POST
		do
			storage.collection_extend (to_store (data))
		end

	force (data: R; key: PATH_PICO)
			-- Equivalent to http PUT
		do
			storage.force (to_store (data), key)
		end

	remove (key: PATH_PICO)
			-- Equivalent to http DELETE
		do
			storage.remove (key)
		end

	merge_update (partial_data: R; key: PATH_PICO)
			-- Equivalent to http PATCH
			-- Apply partial update by merging partial_data into item at key
		deferred
		end

	wipe_out
			-- Remove all items from storage
		do
			across storage.all_keys as key_cursor loop
				storage.remove (key_cursor.item)
			end
		end

feature -- Helpers (delegated)

	last_inserted_key: detachable PATH_PICO
			-- Key of last inserted item
		do
			Result := storage.last_inserted_key
		end

feature -- Internal storage access

	all_keys: ITERABLE [PATH_PICO]
			-- All keys in storage
		do
			Result := storage.all_keys
		end

end
