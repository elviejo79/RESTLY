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
         error_409_conflict: not has_key(k)
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

feature -- Update

	merge (a_patch: JSON_OBJECT; a_k: K)
			-- PATCH: update item at `a_k` with parts named in `a_patch`;
			-- absent parts stay intact.
			-- The patch is a JSON_OBJECT because a partial update is by
			-- definition incomplete — a typed V cannot represent "only
			-- these fields changed."
			-- Default: read current V, merge patch fields via the convert
			-- clauses, put. Descendants may override for optimized merge
			-- (e.g. SQL UPDATE SET on individual columns).
		require
			error_404_not_found: has_key (a_k)
		local
			l_current: JSON_OBJECT
			l_merged: V
		do
			check current_converts_to_json: attached {JSON_OBJECT} item (a_k) as l_json then
				l_current := l_json.twin
			end
			across a_patch.current_keys as ic loop
				l_current.replace (a_patch [ic], ic)
			end
			check merged_converts_back: attached {V} l_current as l_v then
				l_merged := l_v
			end
			put (l_merged, a_k)
		ensure
			key_still_present: has_key (a_k)
		end

feature -- Extension

	extend_new (a_v: V; a_request_id: HASHABLE)
			-- POST: create a new entry with a server-minted key.
			-- Idempotent: a duplicate `a_request_id` with the same value is a no-op.
			-- Default: mint via `fresh_key`, then extend; backends
			-- where the key is born on insert (databases) redefine.
		require
			same_request_means_same_value: True -- TODO(owner): contract
		local
			l_key: K
		do
			if not extend_requests.has_key (a_request_id) then
				l_key := fresh_key (a_v)
				extend (a_v, l_key)
				extend_requests.extend (l_key, a_request_id)
			end
		ensure
			request_recorded: extend_requests.has_key (a_request_id)
			key_present: has_key (extend_requests [a_request_id])
			value_stored: item (extend_requests [a_request_id]) ~ a_v
		end

feature {RESTLY_PROTOCOL} -- Key minting

	fresh_key (a_v: V): K
			-- New unused key for `a_v`; the store's minting policy.
			-- Exported to RESTLY_PROTOCOL (not {NONE}) so combinators
			-- can delegate minting to their components.
			-- TODO(owner): contract (fresh: not has_key (Result))
		deferred
		end

feature -- Access

	extend_requests: V_HASH_TABLE [HASHABLE, K]
			-- Maps request_id -> generated key.
		attribute
			create Result.with_object_equality
		end

feature -- REST verbs (search)

	search (a_query: PREDICATE [V]): RESTLY_PROTOCOL [K, V]
			-- QUERY: all entries matching `a_query` (safe, idempotent).
		require
			error_400_bad_request: True
					-- TODO(owner): contract
					-- suggested: a_query is well-formed per the store's query language
		deferred
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
