note
	description: "[
		A URI_TEMPLATE restricted to http:// or https:// URIs,
		so it can only address remote HTTP endpoints.
		Converts from strings: l_uri := "https://api.example.com".
	]"

class
	RESTLY_HTTP_URI

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

	Uri_RegEx: STRING = "^http[s]?://[^/?#]*(?:/(?:[^/?#]+/)*)?([^/?#]+)(?:\?[^#]*)?(?:#.*)?\z"

end
