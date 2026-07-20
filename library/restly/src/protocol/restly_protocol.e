note
	description: "Minimum set of REST verb abstractions backed by a hash table."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	RESTLY_PROTOCOL [K, V]

inherit
	ANY
		undefine
			is_equal,
			copy,
			out,
			default_create
		end

feature -- REST verbs

	item alias "[]" (k: K): V assign force
			-- GET: value associated with `k`.
		require
			error_404_not_found: has_key (k)
		deferred
		end

	has_key (k: K): BOOLEAN
			-- HEAD: is a resource with key `k` present?
		deferred
		end

	extend (v: V; k: K)
			-- POST: create new resource with key `k`; must not already exist.
		require
			error_403_must_use_fresh_key: not has_key (k)
		deferred
		ensure
			error_500_didnt_actually_update: has_key(k) and then item(k) ~ v 
		end

	force (v: V; k: K)
			-- Upsert row `k` from `v`.
		do
			if has_key (k) then
				put (v, k)
			else
				extend (v, k)
			end
		ensure
			error_500_didnt_actually_insert: has_key(k) and then item(k) ~ v
		end

	put (v: V; k: K)
			-- PUT with exists: update existing resource; `k` must already exist.
		note
			modify: table
		require
			has_key: has_key (k)
		deferred
		ensure
			error_500_didnt_actually_update: item(k) ~ v
		end

	remove (k: K)
			-- DELETE: remove resource with key `k`.
		note
			modify: table
		require
			has_key: has_key (k)
		deferred
		ensure
			error_500_didnt_actually_delete: not has_key(k)
		end

feature -- Output

	graph_description: STRING
			-- Composition rooted at this store as a GraphViz digraph
			-- (SC '19 §4 auto-diagrams; render with `dot -Tpdf').
			-- `a -> b' reads "a is backed by b" — the inversion of
			-- Weiher's source-to-front arrows.
		do
			create Result.make_from_string ("digraph restly {%Nrankdir=LR;%N")
			Result.append (graph_dot_lines)
			Result.append ("}%N")
		end

	graph_node_id: STRING
			-- GraphViz node id, unique per object (address-based).
		do
			Result := "n" + ($Current).out
		end

	graph_dot_lines: STRING
			-- Dot lines for this node and everything behind it.
			-- Leaf default: a single labeled node; combinators
			-- redefine to add their children and labeled edges.
		do
			create Result.make_from_string (graph_node_id)
			Result.append (" [label=%"")
			Result.append (generating_type.name)
			Result.append ("%"];%N")
		end

end
