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
   RESTLY_PROTOCOL[RK, RV]
		redefine
			graph_dot_lines
		end

	RESTLY_LISTABLE [RK, RV]
		redefine
			graph_dot_lines
		end

	RESTLY_POSTABLE[RK, RV]
		redefine
			graph_dot_lines
		end
      
   RESTLY_COMPOSABLE[SK,SV]
   
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
			check postable_back: attached {RESTLY_POSTABLE [SK, SV]} back as l_back then
				l_back.extend_new (storage_value (a_v), a_request_id)
				if not extend_requests.has_key (a_request_id) then
					extend_requests.extend (representation_key (l_back.extend_requests [a_request_id]), a_request_id)
				end
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
