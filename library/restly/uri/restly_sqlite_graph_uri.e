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

feature -- Access

	file_name: STRING_8
			-- Database file the URI names: the part after "scheme://",
			-- without the trailing slash (e.g. ":memory:", "/home/me/db.sqlite").
		local
			l_template: STRING_8
		do
			l_template := template.to_string_8
			Result := l_template.substring (l_template.substring_index ("://", 1) + 3, l_template.count)
			if Result.count > 1 and then Result.ends_with ("/") then
				Result.remove_tail (1)
			end
		end

invariant
	names_a_sqlite_graph_database: template.starts_with ("sqlite+graph://")

end
