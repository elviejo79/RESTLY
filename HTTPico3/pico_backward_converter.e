class PICO_BACKWARD_CONVERTER [R, S -> {PATCHABLE} create make_from_patch end]
	-- Converter where storage (S) is constrained to PATCHABLE
	-- Used when operating with unconstrained types (e.g., JSON) that get stored as PATCHABLE types
	-- Example: R = EJSON_JSON_OBJECT, S = TODO_ITEM_PATCHABLE

inherit
    PICO_CONVERTER [R, S, PICO_REQUEST_METHODS[S]]

create
	make


feature -- Commands with PATCHABLE constraint

	extend_with_patch (a_patch: TABLE_ITERABLE [detachable ANY, STRING])
			-- Type-check representation and delegate patch to backend
		do
			backend.extend_with_patch (a_patch)
			last_inserted_key := backend.last_inserted_key
		end

	patch (a_patch: TABLE_ITERABLE [detachable ANY, STRING]; key: PATH_PICO)
			-- Type-check representation and delegate patch to backend
		do
			backend.patch (a_patch, key)
		end

end
