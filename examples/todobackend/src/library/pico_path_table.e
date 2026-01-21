note
	description: "Summary description for {PICO_PATH_TABLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	PICO_PATH_TABLE[R -> {PATCHABLE} create make_empty, make_from_patch end]

inherit
	HASH_TABLE [R, PATH]
	rename
		extend as hash_extend,
		item as hash_item
	export
		{NONE} all
	undefine
		empty_duplicate
	redefine
		force
	end

	PICO_VERBS[R]
	undefine
		copy, is_equal
	end


feature -- Query

	item alias "/" (key: PATH): R assign force
		do
			check attached hash_item(key) as l_item then
				Result := l_item
			end
      end

	extend (v: R)
		local
			l_key: PATH
		do
			l_key := key_for(v)
			put(v, l_key)
			last_modified_key := l_key
		end

	force (v: R; key: PATH)
		do
			Precursor(v, key)
			last_modified_key := key
		end

feature -- PATCH operations

	patch_ds: TUPLE
			-- Patch data structure descriptor
		local
			l_r: R
		do
			create l_r.make_empty
			check attached {TUPLE} l_r.Patch_ds as l_patch_ds then
				Result := l_patch_ds
			end
		end

	patch (a_patch: like patch_ds; key: PATH)
			-- Apply patch to item at key
		local
			l_item: R
		do
			l_item := item (key)
			l_item.patch (a_patch)
			force (l_item, key)
		end

	extend_from_patch (a_patch: like patch_ds)
			-- Create new item from patch
		local
			l_item: R
		do
			create l_item.make_from_patch (a_patch)
			extend (l_item)
		end

feature {NONE} -- Implementation

	empty_duplicate (n: INTEGER): like Current
		deferred
		end

end
