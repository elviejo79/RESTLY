note
	description: "[
		Pipeline stage converting between the wire types
		[STRING, JSON_OBJECT] and a typed store [K, R].
		Descendants effect the four conversion points as one-liners
		where their domain's convert clauses fire (conversion never
		fires on formal generics — hence this explicit stage).
	]"

deferred class
	RESTLY_CONVERTER [K -> HASHABLE, R]

inherit
	RESTLY_LISTABLE [STRING, JSON_OBJECT]
		redefine
			graph_dot_lines
		end

	RESTLY_POSTABLE [STRING, JSON_OBJECT]
		redefine
			extend_new,
			graph_dot_lines
		end

	ANY
			-- Re-effects default_create/copy/out/is_equal,
			-- which RESTLY_PROTOCOL undefines for its own joins.

feature -- Composition

	backed_by alias "<|" (a_back: RESTLY_PROTOCOL [K, R]): like Current
			-- Current, backed by `a_back`.
		do
			back := a_back
			Result := Current
		end

	accepts (a_candidate: RESTLY_PROTOCOL [ANY, ANY]): BOOLEAN
			-- Can `a_candidate` back this stage?
			-- Answered here because K and R are bound in this class,
			-- so callers holding only [ANY, ANY] views can ask before
			-- delegating (a catcall fires before any precondition could).
		do
			Result := attached {RESTLY_PROTOCOL [K, R]} a_candidate
		end

feature -- Access

	back: RESTLY_PROTOCOL [K, R]
			-- Backing typed store.
		attribute
			-- ponytail: placeholder empty store until `backed_by` sets the real pipeline
			create {RESOURCE_HASH_TABLE [K, R]} Result.make ("unmounted")
		end

feature -- Conversion points

	to_key (a_raw: STRING): K
			-- Key denoted by `a_raw`.
		deferred
		end

	raw_key (a_k: K): STRING
			-- Wire form of `a_k`.
		deferred
		ensure
			round_trip: to_key (Result) ~ a_k
		end

	to_json (a_r: R): JSON_OBJECT
			-- Wire representation of `a_r`.
		deferred
		end

	from_json (a_json: JSON_OBJECT): R
			-- Representation carried by `a_json`.
		deferred
		end

feature -- REST verbs

	item alias "[]" (k: STRING): JSON_OBJECT assign force
			-- <Precursor>
		do
			Result := to_json (back [to_key (k)])
		end

	has_key (k: STRING): BOOLEAN
			-- <Precursor>
		do
			Result := back.has_key (to_key (k))
		end

	extend (v: JSON_OBJECT; k: STRING)
			-- <Precursor>
		do
			back.extend (from_json (v), to_key (k))
		end

	put (v: JSON_OBJECT; k: STRING)
			-- <Precursor>
		do
			back.put (from_json (v), to_key (k))
		end

	remove (k: STRING)
			-- <Precursor>
		do
			back.remove (to_key (k))
		end

feature -- Iteration

	count: INTEGER
			-- <Precursor>
		do
			if attached {RESTLY_LISTABLE [K, R]} back as l_list then
				Result := l_list.count
			end
		end

	new_cursor: TABLE_ITERATION_CURSOR [JSON_OBJECT, STRING]
			-- <Precursor>
			-- ponytail: snapshot per iteration; streaming adapter if collections grow.
		local
			l_snapshot: V_HASH_TABLE [STRING, JSON_OBJECT]
			l_cursor: TABLE_ITERATION_CURSOR [R, K]
		do
			create l_snapshot.with_object_equality
			if attached {RESTLY_LISTABLE [K, R]} back as l_list then
				from
					l_cursor := l_list.new_cursor
				until
					l_cursor.after
				loop
					l_snapshot.extend (to_json (l_cursor.item), raw_key (l_cursor.key))
					l_cursor.forth
				end
			end
			create {RESTLY_V_MAP_CURSOR [STRING, JSON_OBJECT]} Result.make (l_snapshot.new_cursor)
		end

feature -- Removal

	wipe_out
			-- <Precursor>
		do
			if attached {RESTLY_LISTABLE [K, R]} back as l_list then
				l_list.wipe_out
			end
		end

feature -- Extension

	extend_new (a_v: JSON_OBJECT; a_request_id: HASHABLE)
			-- <Precursor>: forwarded in R-space so the domain
			-- store's key minting (fresh_key, set_id) runs;
			-- the minted key is mirrored into `extend_requests`
			-- in wire form (attribute cannot be redefined into a
			-- derived query — ECMA redeclaration is one-directional).
		do
			check postable_back: attached {RESTLY_POSTABLE [K, R]} back as l_back then
				l_back.extend_new (from_json (a_v), a_request_id)
				if not extend_requests.has_key (a_request_id) then
					extend_requests.extend (raw_key (l_back.extend_requests [a_request_id]), a_request_id)
				end
			end
		end

feature -- Key minting

	fresh_key: STRING
			-- <Precursor>
		do
			check postable_back: attached {RESTLY_POSTABLE [K, R]} back as l_back then
				Result := raw_key (l_back.fresh_key)
			end
		end

feature -- Output

	graph_dot_lines: STRING
			-- <Precursor>: self node plus edge to `back`.
		do
			create Result.make_from_string (graph_node_id)
			Result.append (" [label=%"")
			Result.append (generating_type.name)
			Result.append ("%"];%N")
			Result.append (back.graph_dot_lines)
			Result.append (graph_node_id + " -> " + back.graph_node_id + " [label=%"back%"];%N")
		end

end
