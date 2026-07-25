note
	description: "[
		Or-else combinator: every verb tries `front` first; if the key
		is not present there, falls through to `back`.
		Reads search both (front or else back). Writes land in
		whichever store owns the key. Extends go to front (preferred).
	]"

class
	FRONT_OR_ELSE [K -> HASHABLE, V -> ANY]

inherit
	RESTLY_BINARY_COMBINATOR [K, V]

	RESTLY_PROTOCOL [K, V]
		redefine
			graph_dot_lines
		end

	ANY

create
	make

feature -- REST verbs

	has_key (k: K): BOOLEAN
		do
			Result := front.has_key (k) or else back.has_key (k)
		end

	item alias "[]" (k: K): V assign force
		do
			if front.has_key (k) then
				Result := front.item (k)
			else
				check attached {V} back.item (k) as v then
					Result := v
				end
			end
		end

	extend (v: V; k: K)
		do
			front.extend (v, k)
		end

	put (v: V; k: K)
		do
			if front.has_key (k) then
				front.put (v, k)
			else
				back.put (v, k)
			end
		end

	remove (k: K)
		do
			if front.has_key (k) then
				front.remove (k)
			else
				back.remove (k)
			end
		end

feature -- Output

	graph_dot_lines: STRING
		do
			create Result.make_from_string (graph_node_id)
			Result.append (" [label=%"")
			Result.append (generating_type.name)
			Result.append ("%"];%N")
			Result.append (front.graph_dot_lines)
			Result.append (graph_node_id + " -> " + front.graph_node_id + " [label=%"front%"];%N")
			Result.append (back.graph_dot_lines)
			Result.append (graph_node_id + " -> " + back.graph_node_id + " [label=%"back%"];%N")
		end

end
