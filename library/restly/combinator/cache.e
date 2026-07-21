note
	description: "Cache combinator: serves reads from fast `front`, falls through to `back` on miss; writes go through to both."
	author: "agarciafdz@gmail.com"

class
	CACHE [K -> ANY, V -> ANY]

inherit
	COMBINATOR [K, V]
		redefine
			graph_dot_lines
		end

create
	make,
	make_with_back

feature -- ANY

	is_equal (other: like Current): BOOLEAN
		do
			Result := front ~ other.front and then back ~ other.back
		end

	copy (other: like Current)
		do
			front := other.front
			back := other.back
		end

	out: STRING
		do
			create Result.make_from_string (generating_type.name)
		end

	default_create
		do
		end

feature -- Factory

	new_with_parts (a_front: RESTLY_PROTOCOL [K, V]; a_back: detachable RESTLY_PROTOCOL [ANY, ANY]): CACHE [K, V]
			-- <Precursor>
		do
			if attached a_back as b then
				create Result.make_with_back (a_front, b)
			else
				create Result.make (a_front)
			end
		end

feature -- REST verbs

	has_key (k: K): BOOLEAN
		do
			Result := front.has_key (k) or else
				(attached back as b and then b.has_key (k))
		end

	item alias "[]" (k: K): V assign force
		do
			if front.has_key (k) then
				Result := front.item (k)
			else
				-- cache miss: key is in back (guaranteed by precondition has_key)
				check attached back as b and then attached {V} b.item (k) as v then
					Result := v
					front.force (v, k)
				end
			end
		end

	extend (v: V; k: K)
		do
			front.extend (v, k)
			if attached back as b then
				b.extend (v, k)
			end
		end

	put (v: V; k: K)
		do
			if front.has_key (k) then
				front.put (v, k)
			else
				-- key is in back but not yet cached; populate front on write
				front.force (v, k)
			end
			if attached back as b then
				b.put (v, k)
			end
		end

	remove (k: K)
		do
			if front.has_key (k) then
				front.remove (k)
			end
			if attached back as b and then b.has_key (k) then
				b.remove (k)
			end
		end

feature -- Output

	graph_dot_lines: STRING
			-- <Precursor>
			-- Edges to `front` and (when attached) `back`.
		do
			create Result.make_from_string (graph_node_id)
			Result.append (" [label=%"")
			Result.append (generating_type.name)
			Result.append ("%"];%N")
			Result.append (front.graph_dot_lines)
			Result.append (graph_node_id + " -> " + front.graph_node_id + " [label=%"front%"];%N")
			if attached back as b then
				Result.append (b.graph_dot_lines)
				Result.append (graph_node_id + " -> " + b.graph_node_id + " [label=%"back%"];%N")
			end
		end

end -- class
