class
	RESTLY_DIRECTORY_URI

inherit
	RESTLY_URI
		redefine
			Uri_RegEx
		end

create
	make,
	make_from_uri_template

convert
	make ({READABLE_STRING_8, STRING_8}),
	template: {READABLE_STRING_8}

feature -- Uri template

	Uri_RegEx: STRING = "^/(?:[^/]+/)*\z"
			-- Input	                        Result
			-- /a_dir/a_sub_dir/	            ✓ / + a_dir/ + a_sub_dir/
			-- /                             ✓ zero repetitions of the group
			-- /a_dir/my_file.txt            ✗ my_file.txt has no trailing /

end
