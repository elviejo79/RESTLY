note
	description: "Generic in-memory table for PATCHABLE items with automatic key generation"

class
	PICO_MEMORY_TABLE[R -> {PATCHABLE} create make_empty, make_from_patch end]

inherit
	PICO_PATH_TABLE[R, TUPLE]
		rename
			make as make_hash_table
		end

create
	make

feature -- Initialization

	make (n: INTEGER)
		do
			make_hash_table (n)
			create last_modified_key.make_from_string ("")
		end

feature -- Implementation of PICO_VERBS

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
			force (l_item, key)  -- Parent sets last_modified_key
		end

	extend_from_patch (a_patch: like patch_ds)
			-- Create new item from patch
		local
			l_item: R
		do
			create l_item.make_from_patch (a_patch)
			extend (l_item)  -- Parent sets last_modified_key
		end

	key_for (v: R): PATH
			-- Auto-increment key generation
		do
			create Result.make_from_string (count.out)
		end

feature {NONE} -- Implementation

	empty_duplicate (n: INTEGER): like Current
		do
			create Result.make (n)
		end

end
