class
	RESTLY_FILE_URI

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

	Uri_RegEx: STRING = "^(?:/(?:[^/]+/)*)?[^/]+\z"
			-- Input	                           Result
			-- my_file.txt	                     ✓ optional group absent, [^/]+ eats the lot
			-- /a_dir/a_sub_dir/my_file.txt	   ✓ / + a_dir/a_sub_dir/ + my_file.txt

end
