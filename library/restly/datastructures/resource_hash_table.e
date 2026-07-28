note
	description: "[
		Named REST resource backed by an owned V_HASH_TABLE.
		Composition, not inheritance: V_TABLE's ancestry expects
		new_cursor to be a V_ITERATOR, which a streaming
		TABLE_ITERATION_CURSOR cannot honestly be.
	]"

class
	RESOURCE_HASH_TABLE [K -> HASHABLE, V]

inherit
	RESTLY_LISTABLE [K, V]

	ANY

create
	make

feature {NONE} -- Initialization

	make (a_name: STRING)
			-- Empty store named `a_name` with object equality on keys.
		do
			name := a_name
			create table.with_object_equality
		end

feature -- Access

	name: STRING
			-- Resource name (e.g. collection segment of the URI).

feature -- REST verbs

	item alias "[]" (k: K): V assign force
			-- <Precursor>
		do
			Result := table [k]
		end

	has_key (k: K): BOOLEAN
			-- <Precursor>
		do
			Result := table.has_key (k)
		end

	extend (v: V; k: K)
			-- <Precursor>
		do
			table.extend (v, k)
		end

	put (v: V; k: K)
			-- <Precursor>
		do
			table.put (v, k)
		end

	remove (k: K)
			-- <Precursor>
		do
			table.remove (k)
		end

feature -- Search

	search (a_query: PREDICATE [V]): RESTLY_PROTOCOL [K, V]
			-- <Precursor>: linear scan of the table.
		local
			l_matches: RESOURCE_HASH_TABLE [K, V]
			l_cursor: TABLE_ITERATION_CURSOR [V, K]
		do
			create l_matches.make (name + "_search")
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

	fresh_key (a_v: V): K
			-- <Precursor>: a generic table cannot invent a K;
			-- key-minting descendants (TODO_STORE, ...) redefine.
		do
			check minting_needs_a_concrete_key_type: False then
				Result := fresh_key (a_v)
			end
		end

feature -- Iteration

	new_cursor: TABLE_ITERATION_CURSOR [V, K]
			-- <Precursor>
		do
			create {RESTLY_V_MAP_CURSOR [K, V]} Result.make (table.new_cursor)
		end

feature -- Removal

	wipe_out
			-- <Precursor>
		do
			table.wipe_out
		end

feature {NONE} -- Implementation

	table: V_HASH_TABLE [K, V]
			-- Owned backing table (object equality on keys).
		attribute
			create Result.with_object_equality
		end

end
