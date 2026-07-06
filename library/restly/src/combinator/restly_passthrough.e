note
	description: "[
		PassThrough combinator: forwards every verb unchanged
		to `backend`. The identity element of the composition
		(Storage Combinators, Onward! '19) — insertable anywhere
		in a pipeline without observable change.
	]"

class
	RESTLY_PASSTHROUGH [K -> HASHABLE, V]

inherit
	ANY

	RESTLY_PROTOCOL [K, V]
		redefine
			graph_dot_lines
		end

create
	make

feature {NONE} -- Initialization

	make (a_backend: RESTLY_PROTOCOL [K, V])
			-- Forward all verbs to `a_backend`.
		do
			backend := a_backend
		end

feature -- Components

	backend: RESTLY_PROTOCOL [K, V]
			-- The store every verb forwards to.

feature -- Chaining

	backed_by alias "<|" (a_back: RESTLY_PROTOCOL [K, V]): like Current
			-- Swap the backend; return Current for chaining.
		do
			backend := a_back
			Result := Current
		end

feature -- REST verbs

	item alias "[]" (k: K): V assign force
			-- <Precursor>
		do
			Result := backend.item (k)
		end

	has_key (k: K): BOOLEAN
			-- <Precursor>
		do
			Result := backend.has_key (k)
		end

	extend (v: V; k: K)
			-- <Precursor>
		do
			backend.extend (v, k)
		end

	force (v: V; k: K)
			-- <Precursor>
		do
			backend.force (v, k)
		end

	put (v: V; k: K)
			-- <Precursor>
		do
			backend.put (v, k)
		end

	remove (k: K)
			-- <Precursor>
		do
			backend.remove (k)
		end

feature -- Output

	graph_dot_lines: STRING
			-- <Precursor>
		do
			create Result.make_from_string (graph_node_id)
			Result.append (" [label=%"")
			Result.append (generating_type.name)
			Result.append ("%"];%N")
			Result.append (backend.graph_dot_lines)
			Result.append (graph_node_id + " -> " + backend.graph_node_id + " [label=%"backend%"];%N")
		end

end
