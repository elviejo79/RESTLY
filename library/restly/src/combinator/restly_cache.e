note
	description: "Cache combinator: serves reads from fast `front`, falls through to `back` on miss; writes go through to both."
	author: "agarciafdz@gmail.com"

class
	RESTLY_CACHE [K -> HASHABLE, V]

inherit
	RESTLY_BASIC_COMBINATOR [K, V, V]
		redefine
			graph_dot_lines
		end

create
	make,
	make_with_back

feature -- Creation

	make_with_back (a_front: RESTLY_PROTOCOL [K, V]; a_back: RESTLY_PROTOCOL [K, V])
		do
			front := a_front
			back := a_back
		end

feature -- Factory

	new_with_front alias "-" (a_front: RESTLY_PROTOCOL [K, V]): RESTLY_CACHE [K, V]
		do
			create Result.make (a_front)
		ensure then
			instance_free: class
		end

	backed_by alias "<|" (a_back: RESTLY_PROTOCOL [K, V]): RESTLY_CACHE [K, V]
		do
			if attached {RESTLY_BASIC_COMBINATOR [K, V, V]} back as b then
				create Result.make_with_back (front, b <| a_back)
			else
				create Result.make_with_back (front, a_back)
			end
		end

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
				check attached back as b then
					Result := b.item (k)
					front.force (Result, k)
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

	force (v: V; k: K)
		do
			front.force (v, k)
			if attached back as b then
				b.force (v, k)
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
