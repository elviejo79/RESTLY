note
	description: "One granted scope from a credential (e.g. one word of a JWT `scope` claim)."

class
	SCOPE

inherit
	ANY
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

feature -- Comparison

	is_equal (other: like Current): BOOLEAN
		do
			Result := name ~ other.name
		end

end
