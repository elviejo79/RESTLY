note
	description: "Wrapper for STRING_8 that implements CONVERTIBLE_TO for identity conversion"
	author: "HTTPico Team"
	date: "$Date$"
	revision: "$Revision$"

class
	STRING_CONVERTIBLE

inherit
	CONVERTIBLE_TO[STRING]
		redefine
			out
		end

create
	make,
	make_from_string,
	make_from_s

feature {NONE} -- Initialization

	make (a_string: STRING)
			-- Initialize with a string
		do
			value := a_string
		ensure
			value_set: value = a_string
		end

	make_from_string (a_string: STRING)
			-- Alias for make
		do
			make (a_string)
		end

	make_from_s (a_string: STRING)
			-- CONVERTIBLE_TO implementation
		do
			make (a_string)
		end

feature -- Access

	value: STRING
			-- The wrapped string value

	to_s: STRING
			-- Convert to STRING (identity conversion)
		do
			Result := value
		end

	out: STRING
			-- String representation
		do
			Result := value
		end

end
