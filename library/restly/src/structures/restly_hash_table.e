note
	description: "[
		REST verbs backed by an owned V_HASH_TABLE.
		Composition, not inheritance: V_TABLE's ancestry expects
		new_cursor to be a V_ITERATOR, which a streaming
		TABLE_ITERATION_CURSOR cannot honestly be.
	]"

class
	RESTLY_HASH_TABLE [K -> HASHABLE, V]

inherit
	RESTLY_LISTABLE [K, V]

	ANY

create
	default_create,
	with_object_equality

feature {NONE} -- Initialization

	with_object_equality
			-- Empty store with object equality as equivalence relation on keys.
		do
			create table.with_object_equality
		end

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
			-- Owned backing table (reference equality unless
			-- created `with_object_equality`).
		attribute
			create Result
		end

end
