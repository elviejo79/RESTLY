class PICO_FORWARD_CONVERTER [R -> {PATCHABLE} create make_from_patch end, S]
	-- Converter where representation (R) is constrained to PATCHABLE
	-- Used when operating with PATCHABLE types that get stored as unconstrained types
	-- Example: R = TODO_ITEM_PATCHABLE, S = JSON_VALUE

inherit
	PICO_CONVERTER [R, S, PICO_REQUEST_METHODS_UNCONSTRAINED[S]]

	PICO_REQUEST_METHODS[R]

create
	make

feature -- Internal storage


feature -- Commands with PATCHABLE constraint

	extend_with_patch (a_patch: HASH_TABLE [detachable ANY, STRING])
			-- Create representation from patch, convert to storage, and extend backend
		local
			l_representation: R
			l_storage: S
		do
			create l_representation.make_from_patch (a_patch)
			l_storage := to_storage (l_representation)
			backend.extend (l_storage)
			last_inserted_key := backend.last_inserted_key
		end

	patch (a_patch: HASH_TABLE [detachable ANY, STRING]; key: PATH_PICO)
			-- Create representation from patch, convert to storage, and force to backend
		local
			l_representation: R
			l_storage: S
		do
			create l_representation.make_from_patch (a_patch)
			l_storage := to_storage (l_representation)
			backend.force (l_storage, key)
		end


end
