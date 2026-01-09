class PICO_PATH_TABLE [R -> {PATCHABLE} create make_from_patch end]

inherit
	PICO_PATH_TABLE_UNCONSTRAINED [R]
		undefine copy, is_equal
		redefine patch, extend_with_patch
		end
	PICO_REQUEST_METHODS[R]

create
	make

feature -- Commands

	extend_with_patch (a_patch: HASH_TABLE[detachable ANY, STRING])
		local
			l_rep: R
		do
			create l_rep.make_from_patch (a_patch)
			last_inserted_key := key_for (l_rep)
			extend (l_rep)
		end

	patch (a_patch: HASH_TABLE[detachable ANY, STRING]; key: PATH_PICO)
		local
			l_rep: R
		do
            l_rep := item(key)
            l_rep.update_from_patch(a_patch)
			force (l_rep, key)
			last_inserted_key := key
		end

end
