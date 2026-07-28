note
	description: "[
		Pipeline stage converting between the wire types
		[STRING, JSON_OBJECT] and a typed store [K, R].
		Descendants effect the four conversion points as one-liners
		where their domain's convert clauses fire (conversion never
		fires on formal generics — hence this explicit stage).
	]"

deferred class
	CONVERTER [RK -> HASHABLE, RV, SK -> HASHABLE, SV]

inherit
	RESTLY_LISTABLE [RK, RV]
		redefine
			graph_dot_lines,
			extend_new
		end

	RESTLY_UNARY_COMBINATOR [SK, SV]
   
	ANY
			-- Re-effects default_create/copy/out/is_equal,
			-- which RESTLY_PROTOCOL undefines for its own joins.


feature -- Conversion points

	storage_key (a_key: RK): SK
			-- Storage key denoted by `a_key`.
		deferred
		end

	representation_key (a_key: SK): RK
			-- Representation of `a_key`.
		deferred
		ensure
			round_trip: storage_key (Result) ~ a_key
		end

	representation (a_value: SV): RV
			-- Representation of `a_value`.
		deferred
		end

	storage_value (a_value: RV): SV
			-- Storage value carried by `a_value`.
		deferred
		end

feature -- REST verbs

	item alias "[]" (k: RK): RV assign force
			-- <Precursor>
		do
			Result := representation (back [storage_key (k)])
		end

	has_key (k: RK): BOOLEAN
			-- <Precursor>
		do
			Result := back.has_key (storage_key (k))
		end

	extend (v: RV; k: RK)
			-- <Precursor>
		do
			back.extend (storage_value (v), storage_key (k))
		end

	put (v: RV; k: RK)
			-- <Precursor>
		do
			back.put (storage_value (v), storage_key (k))
		end

	remove (k: RK)
			-- <Precursor>
		do
			back.remove (storage_key (k))
		end

feature -- Iteration

	new_cursor: TABLE_ITERATION_CURSOR [RV, RK]
			-- <Precursor>
			-- ponytail: snapshot per iteration; streaming adapter if collections grow.
		local
			l_snapshot: V_HASH_TABLE [RK, RV]
			l_cursor: TABLE_ITERATION_CURSOR [SV, SK]
		do
			create l_snapshot.with_object_equality
			if attached {RESTLY_LISTABLE [SK, SV]} back as l_list then
				from
					l_cursor := l_list.new_cursor
				until
					l_cursor.after
				loop
					l_snapshot.extend (representation (l_cursor.item), representation_key (l_cursor.key))
					l_cursor.forth
				end
			end
			create {RESTLY_V_MAP_CURSOR [RK, RV]} Result.make (l_snapshot.new_cursor)
		end

feature -- Removal

	wipe_out
			-- <Precursor>
		do
			if attached {RESTLY_LISTABLE [SK, SV]} back as l_list then
				l_list.wipe_out
			end
		end

feature -- Extension

	extend_new (a_v: RV; a_request_id: HASHABLE)
			-- <Precursor>: forwarded in R-space so the domain
			-- store's key minting runs;
			-- the minted key is mirrored into `extend_requests`
			-- in wire form (attribute cannot be redefined into a
			-- derived query — ECMA redeclaration is one-directional).
		do
			back.extend_new (storage_value (a_v), a_request_id)
			if not extend_requests.has_key (a_request_id) then
				extend_requests.extend (representation_key (back.extend_requests [a_request_id]), a_request_id)
			end
		end

feature -- Search

	search (a_query: PREDICATE [RV]): RESTLY_PROTOCOL [RK, RV]
			-- <Precursor>: filter own cursor in R-space; a predicate
			-- over RV cannot be pushed through the conversion to `back`.
		local
			l_matches: RESOURCE_HASH_TABLE [RK, RV]
			l_cursor: TABLE_ITERATION_CURSOR [RV, RK]
		do
			create l_matches.make ("search_results")
			from
				l_cursor := new_cursor
			until
				l_cursor.after
			loop
				if a_query (l_cursor.item) then
					l_matches.extend (l_cursor.item, l_cursor.key)
				end
				l_cursor.forth
			end
			Result := l_matches
		end

feature {RESTLY_PROTOCOL} -- Key minting

	fresh_key (a_v: RV): RK
			-- <Precursor>: never ours -- the store behind `back` mints.
		do
			check this_should_never_be_called: False then
				Result := fresh_key (a_v)
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
