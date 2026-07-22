note
	description: "[
		A URI_TEMPLATE restricted to sqlite+graph:// URIs,
		addressing SQLite files holding ABEL's generic object-graph
		layout (ps_* tables) rather than one relational table per type.
		Converts from strings: l_uri := "sqlite+graph://:memory:/".
	]"

class
	RESTLY_SQLITE_GRAPH_URI

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
	names_a_sqlite_graph_database: template.starts_with ("sqlite+graph://")

end
