note
	description: "[
		A URI_TEMPLATE restricted to file:/// URIs (RFC 3986),
		so it can only address local filesystem paths.
		Converts from strings: l_uri := "file:///home/me/dir/".
	]"

class
	RESTLY_FILE_URI

inherit
	URI_TEMPLATE

create
	make,
	make_from_uri_template

convert
	make ({READABLE_STRING_8, STRING_8}),
	template: {READABLE_STRING_8}

invariant
	names_a_local_directory: template.starts_with ("file:///")

end
