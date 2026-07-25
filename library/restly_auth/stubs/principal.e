note
	description: "Verified identity: who a capability speaks for."

class
	PRINCIPAL

inherit
	HASHABLE
		redefine
			is_equal
		end

create
	make

feature {NONE} -- Initialization

	make (a_name: READABLE_STRING_GENERAL)
		do
			name := a_name.to_string_8
		end

feature -- Access

	name: STRING

	hash_code: INTEGER
		do
			Result := name.hash_code
		end

feature -- Comparison

	is_equal (other: like Current): BOOLEAN
			-- By name, not by reference (ground rule 8: `~` everywhere).
		do
			Result := name ~ other.name
		end

end
