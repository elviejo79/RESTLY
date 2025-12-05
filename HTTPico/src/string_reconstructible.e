note
	description: "[
		Interface for types that can be converted to/from STRING.
		Combines CONVERTIBLE_TO with a creation constraint for make_from_string.
	]"
	author: "Alejandro Garcia"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	STRING_RECONSTRUCTIBLE

inherit
	CONVERTIBLE_TO[STRING]

feature {NONE} -- Creation

	make_from_string (a_string: STRING)
			-- Create from string representation
		deferred
		end

end
