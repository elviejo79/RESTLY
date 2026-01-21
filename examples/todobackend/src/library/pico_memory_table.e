note
	description: "Generic in-memory table for PATCHABLE items with automatic key generation"

class
	PICO_MEMORY_TABLE[R -> {PATCHABLE} create make_empty, make_from_patch end]

inherit
	PICO_PATH_TABLE[R]

create
	make

feature -- Key generation

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
