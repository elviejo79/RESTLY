note
	description: "[
		The FRONT of a pipeline: the ONE home of the capability
		interfaces (POSTABLE, PATCHABLE, LISTABLE).
		Everything behind it is pure RESTLY_PROTOCOL.
		Holds store and both converters as explicit creation arguments.
	]"

deferred class
	RESTLY_PIPELINE_FRONT [KR -> HASHABLE, R, KS -> HASHABLE, S]

inherit
	ANY

	RESTLY_POSTABLE [KR, R]
		redefine
			extend_new,
			graph_dot_lines
		end

	RESTLY_PATCHABLE [KR, R]
		redefine
			graph_dot_lines
		end

	RESTLY_LISTABLE [KR, R]
		redefine
			graph_dot_lines
		end

feature {NONE} -- Initialization

	make (a_store: RESTLY_PROTOCOL [KS, S]; a_key_converter: RESTLY_KEY_CONVERTER [KR, KS]; a_converter: RESTLY_CONVERTER [R, S])
			-- Wire the pipeline front.
		do
			store := a_store
			key_converter := a_key_converter
			converter := a_converter
		end

feature -- Chaining

	backed_by alias "<|" (a_back: RESTLY_PROTOCOL [KS, S]): like Current
			-- Set the backing store; return Current for chaining.
		do
			store := a_back
			Result := Current
		end

feature -- Components

	store: RESTLY_PROTOCOL [KS, S]
			-- Backing storage.

	key_converter: RESTLY_KEY_CONVERTER [KR, KS]
			-- Converts between representation keys and store keys.

	converter: RESTLY_CONVERTER [R, S]
			-- Converts between representation values and store values.

feature -- REST verbs

	item alias "[]" (k: KR): R assign force
			-- GET: retrieve and convert.
		do
			Result := converter.to_representation (store.item (key_converter.to_store (k)))
		end

	has_key (k: KR): BOOLEAN
			-- HEAD: is the key present?
		do
			Result := store.has_key (key_converter.to_store (k))
		end

	extend (v: R; k: KR)
			-- POST: create new entry with conversion.
		do
			store.extend (converter.to_store (v), key_converter.to_store (k))
		end

	put (v: R; k: KR)
			-- PUT with exists: update with conversion.
		do
			store.put (converter.to_store (v), key_converter.to_store (k))
		end

	remove (k: KR)
			-- DELETE: remove entry.
		do
			store.remove (key_converter.to_store (k))
		end

feature -- Extension (RESTLY_POSTABLE)

	extend_new (a_v: R; a_request_id: HASHABLE)
			-- <Precursor>
			-- A POSTABLE store mints its own keys (e.g. database
			-- autoincrement): delegate and convert the minted key back.
			-- Otherwise mint here via `fresh_key`.
		local
			l_store_key: KS
			l_repr_key: KR
		do
			if not extend_requests.has_key (a_request_id) then
				if attached {RESTLY_POSTABLE [KS, S]} store as l_postable then
					l_postable.extend_new (converter.to_store (a_v), a_request_id)
					l_repr_key := key_converter.to_representation (l_postable.extend_requests [a_request_id])
				else
					l_repr_key := fresh_key
					l_store_key := key_converter.to_store (l_repr_key)
					store.extend (converter.to_store (a_v), l_store_key)
				end
				extend_requests.extend (l_repr_key, a_request_id)
			end
		end

feature -- Listing (RESTLY_LISTABLE)

	new_cursor: TABLE_ITERATION_CURSOR [R, KR]
			-- Lazily converting stream over the store's cursor.
		do
			create {RESTLY_CONVERTING_CURSOR [KR, R, KS, S]} Result.make (store_traversable.new_cursor, key_converter, converter)
		end

	count: INTEGER
			-- Number of entries in the store.
		do
			Result := store_traversable.count
		end

	wipe_out
			-- Remove all entries from the store.
		do
			store_traversable.wipe_out
		end

feature -- Output

	graph_dot_lines: STRING
			-- <Precursor>
			-- Node labeled with both converters; edge to `store`.
		do
			create Result.make_from_string (graph_node_id)
			Result.append (" [label=%"")
			Result.append (generating_type.name)
			Result.append ("\nkey: ")
			Result.append (key_converter.generating_type.name)
			Result.append ("\nvalue: ")
			Result.append (converter.generating_type.name)
			Result.append ("%"];%N")
			Result.append (store.graph_dot_lines)
			Result.append (graph_node_id + " -> " + store.graph_node_id + " [label=%"store%"];%N")
		end

feature {NONE} -- Implementation

	store_traversable: RESTLY_LISTABLE [KS, S]
			-- Store as traversable.
		do
			check attached {RESTLY_LISTABLE [KS, S]} store as l_trav then
				Result := l_trav
			end
		end

end
