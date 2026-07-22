note
	description: "[
		A URI_TEMPLATE restricted to sqlite:// URIs,
		so it can only address local SQLite database files.
		Converts from strings: l_uri := "sqlite:///home/me/db.sqlite/".
	]"

class
	RESTLY_SQLITE_URI

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
	names_a_sqlite_database: template.starts_with ("sqlite://")

end
