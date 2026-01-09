class
	PATH_PICO

inherit
	STRING_32
		redefine
			default_create,
			make_empty,
			make_from_string
		end

create
	default_create,
	make_empty,
	make_from_string,
	make

convert
   make_from_string({READABLE_STRING_32})

feature {NONE} -- Initialization

	default_create
		do
			make_empty
		end

	make_empty
		do
			Precursor
		end

	make_from_string (s: READABLE_STRING_32)
		do
			Precursor (s)
		end

end
