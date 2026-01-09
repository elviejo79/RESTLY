deferred class PICO_CONVERTER [R, S, B -> {PICO_REQUEST_METHODS_UNCONSTRAINED[S]}]
	-- Base class for bidirectional converters between representation (R) and storage (S)
	-- Provides delegation pattern with automatic conversion between types

inherit
    PICO_REQUEST_METHODS_UNCONSTRAINED[R]
    
feature -- Converters

	to_representation: FUNCTION [S, R]
			-- Function to convert from storage to representation

	to_storage: FUNCTION [R, S]
			-- Function to convert from representation to storage

feature -- Internal storage

	backend: B
			-- Storage backend

feature -- Initialization

	make(a_backend: like backend; a_to_representation: like to_representation; a_to_storage: like to_storage)
		do
			backend := a_backend
			to_representation := a_to_representation
			to_storage := a_to_storage
		end

feature -- Queries

	has (key: PATH_PICO): BOOLEAN
			-- Does backend have an item at `key'?
		do
			Result := backend.has (key)
		end

	item alias "[]" (key: PATH_PICO): R assign force
			-- Item at `key', converted to representation
		do
			check attached backend.item (key) as backend_item then
				Result := to_representation (backend_item)
			end
		end

	linear_representation: LIST [R]
			-- Linear representation of all items
		local
			result_list: ARRAYED_LIST [R]
		do
			-- TODO: Implement proper conversion from backend storage to representation
			-- Currently has SCOOP-related issues with s_item.item access
			create result_list.make (0)
			Result := result_list
		end

	options: LIST [STRING]
			-- Available HTTP options
		do
			Result := backend.options
		end

feature -- Commands

	extend (a_representation: R)
			-- Extend backend with representation, converting to storage
		local
			l_storage: S
		do
			l_storage := to_storage (a_representation)
			backend.extend (l_storage)
			last_inserted_key := backend.last_inserted_key
		end

	force (a_representation: R; key: PATH_PICO)
			-- Force representation at `key', converting to storage
		local
			l_storage: S
		do
			l_storage := to_storage (a_representation)
			backend.force (l_storage, key)
			last_inserted_key := backend.last_inserted_key
		end

feature {NONE} -- Destructive operations

	wipe_out
			-- Remove all items from backend
		do
			backend.wipe_out
		end

	remove (key: PATH_PICO)
			-- Remove item at `key'
		do
			backend.remove (key)
		end

feature -- State of the resource

	key_for (a_representation: R): PATH_PICO
			-- Key for given representation
		do
			Result := backend.key_for (to_storage (a_representation))
		end

feature -- Helpers

	is_empty: BOOLEAN
			-- Is backend empty?
		do
			Result := backend.is_empty
		end


end
