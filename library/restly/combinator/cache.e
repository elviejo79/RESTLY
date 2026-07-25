note
	description: "[
		Cache combinator — and-then semantics: every verb touches
		`front` *and then* `back`. Reads hit front first, fall through
		to back on miss and populate front; writes go through to both.
		Built with the static factory:
			{CACHE [K, V]}.fronted_by (a_front) <| a_back
		A bare `fronted_by` without `<|` trips `wired` on the first verb.
	]"
	author: "agarciafdz@gmail.com"

class
	CACHE [K -> HASHABLE, V -> ANY]

inherit
	RESTLY_BINARY_COMBINATOR [K, V]

	RESTLY_PROTOCOL [K, V]
		redefine
			graph_dot_lines
		end

	ANY
			-- Re-effects default_create/copy/out/is_equal, which
			-- RESTLY_PROTOCOL undefines for its own joins.

create
	make

feature -- Factory

	fronted_by (a_front: RESTLY_PROTOCOL [K, V]): CACHE [K, V]
			-- Fresh cache fronted by `a_front`; back unwired until `<|`.
		do
			create Result.make (a_front)
		ensure
			instance_free: class
		end

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
				check back_speaks_front_value_type: attached {V} back.item (k) as v then
					Result := v
					front.force (v, k)
				end
			end
		end

	extend (v: V; k: K)
		do
			front.extend (v, k)
			back.extend (v, k)
		end

	put (v: V; k: K)
			-- `force` on each part: the key may live in only one of them.
		do
			front.force (v, k)
			back.force (v, k)
		end

	remove (k: K)
		do
			if front.has_key (k) then
				front.remove (k)
			end
			if back.has_key (k) then
				back.remove (k)
			end
		end

feature -- Output

	graph_dot_lines: STRING
			-- <Precursor>
			-- Edges to `front` and the wired `back`.
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
