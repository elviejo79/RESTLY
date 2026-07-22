note
	description: "[
		A URI_TEMPLATE restricted to http:// or https:// URIs,
		so it can only address remote HTTP endpoints.
		Converts from strings: l_uri := "https://api.example.com".
	]"

class
	RESTLY_HTTP_URI

inherit
	URI_TEMPLATE
		export
			{NONE} set_template
		end

create
	make,
	make_from_uri_template

convert
	make ({READABLE_STRING_8, STRING_8}),
	template: {READABLE_STRING_8}

invariant
	names_an_http_endpoint: template.starts_with ("http://") or template.starts_with ("https://")

end
