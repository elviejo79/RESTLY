note
	description: "Singleton storage for TODO items"

once class
	TODO_STORAGE

inherit
PICO_TABLE[TODO_ITEM]
	redefine
		empty_duplicate
	end

create
	make_default

feature {NONE} -- Initialization

	make_default
		once ("PROCESS")
			make (10)
		end

feature -- Duplication

	empty_duplicate (n: INTEGER): like Current
			-- Create an empty copy of array with capacity `n'.
		do
			Result := Current
		end

end
