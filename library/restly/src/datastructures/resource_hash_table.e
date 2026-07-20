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

feature -- Iteration

	new_cursor: TABLE_ITERATION_CURSOR [V, K]
			-- <Precursor>
		do
			create {RESTLY_V_MAP_CURSOR [K, V]} Result.make (table.new_cursor)
		end

	count: INTEGER
			-- <Precursor>
		do
			Result := table.count
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
