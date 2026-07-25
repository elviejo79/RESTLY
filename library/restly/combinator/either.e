note
	description: "[
		Either combinator: routes each REST verb to `front` or `back`
		based on per-verb template methods. Descendants effect the five
		deferred queries (front_has, front_reads, front_extends,
		front_puts, front_removes) to specialize the routing.
		True → front, False → back.
	]"

deferred class
	EITHER [K -> HASHABLE, V -> ANY]

inherit
	RESTLY_BINARY_COMBINATOR [K, V]

	RESTLY_PROTOCOL [K, V]
		redefine
			graph_dot_lines
		end

	ANY

feature -- Routing (template methods)

	front_has (k: K): BOOLEAN
		deferred
		end

	front_reads (k: K): BOOLEAN
		deferred
		end

	front_extends (v: V; k: K): BOOLEAN
		deferred
		end

	front_puts (v: V; k: K): BOOLEAN
		deferred
		end

	front_removes (k: K): BOOLEAN
		deferred
		end

feature -- REST verbs

	has_key (k: K): BOOLEAN
		do
			if front_has (k) then
				Result := front.has_key (k)
			else
				Result := back.has_key (k)
			end
		end

	item alias "[]" (k: K): V assign force
		do
			if front_reads (k) then
				Result := front.item (k)
			else
				check attached {V} back.item (k) as v then
					Result := v
				end
			end
		end

	extend (v: V; k: K)
		do
			if front_extends (v, k) then
				front.extend (v, k)
			else
				back.extend (v, k)
			end
		end

	put (v: V; k: K)
		do
			if front_puts (v, k) then
				front.put (v, k)
			else
				back.put (v, k)
			end
		end

	remove (k: K)
		do
			if front_removes (k) then
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
