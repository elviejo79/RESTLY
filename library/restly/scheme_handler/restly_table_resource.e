note
	description: "[
		One relational table as the authoritative RESTLY store of
		typed objects (nothing stands behind it).
		Keys are row ids; values are Vs, (de)serialized by ABEL.
		Identity is the table; serialization is never ours.
		Addressable: base_url is the owning database's URL plus the
		table name, e.g. "sqlite://:memory:/todo_row/".
	]"

class
	RESTLY_TABLE_RESOURCE [V -> RESTLY_IDENTIFIABLE [INTEGER]]

inherit
	RESTLY_LISTABLE [INTEGER, V]
		redefine
			extend_new
		end

	RESTLY_RESOURCE

	PS_ABEL_EXPORT
			-- Grants access to ABEL internals: {PS_DEFAULT_REPOSITORY}.delete
			-- and {PS_TRANSACTION}.transaction, needed because ABEL's public
			-- API only deletes via garbage collection, which the relational
			-- backend cannot support (root status is not persisted in rows).

create
	make

feature {NONE} -- Initialization

	make (a_table: RESTLY_TABLE_HANDLE)
			-- Store backed by ABEL repository reached through `a_table`.
		do
			table := a_table
			create base_url.make (a_table.database.base_url.template + table_name + "/")
		end

feature -- REST verbs

	has_key (k: INTEGER): BOOLEAN
			-- Is there a row with id `k`?
		local
			l_query: PS_QUERY [V]
		do
			l_query := executed_key_query (k)
			Result := not l_query.new_cursor.after
			l_query.close
		end

	item alias "[]" (k: INTEGER): V assign force
			-- Object from row `k` (rows -> V is ABEL's job).
		local
			l_query: PS_QUERY [V]
		do
			l_query := executed_key_query (k)
			Result := l_query.new_cursor.item
			l_query.close
		end

	extend (v: V; k: INTEGER)
			-- Insert `v`; the database mints the id, so this holds its
			-- contract only when `k` is the id the database assigns.
			-- Prefer `extend_new`, which reads the minted id back.
		do
			insert (v)
		end

	put (v: V; k: INTEGER)
			-- Update row `k` from `v`; the key imposes the id, so `v`
			-- need not carry it (REST PUT bodies usually don't).
		local
			l_query: PS_QUERY [V]
			l_cursor: ITERATION_CURSOR [V]
			l_transaction: PS_TRANSACTION
		do
			l_transaction := proxy.new_transaction
			create l_query.make
			l_query.set_criterion (key_criterion (k))
			l_transaction.execute_query (l_query)
			l_cursor := l_query.new_cursor
			if not l_cursor.after then
				l_cursor.item.copy (v)
				l_cursor.item.id := k
				l_transaction.update (l_cursor.item)
			end
			l_query.close
			l_transaction.commit
		end

	remove (k: INTEGER)
			-- Delete row `k`.
		local
			l_query: PS_QUERY [V]
			l_cursor: ITERATION_CURSOR [V]
			l_transaction: PS_TRANSACTION
		do
			l_transaction := proxy.new_transaction
			create l_query.make
			l_query.set_criterion (key_criterion (k))
			l_transaction.execute_query (l_query)
			l_cursor := l_query.new_cursor
			if not l_cursor.after then
				check repository_is_default: attached {PS_DEFAULT_REPOSITORY} proxy as l_repository then
					l_repository.delete (l_cursor.item, l_transaction.transaction)
				end
			end
			l_query.close
			l_transaction.commit
		end

	search (a_query: PREDICATE [V]): RESTLY_PROTOCOL [INTEGER, V]
			-- <Precursor>: criterion-less query filtered in memory.
			-- ponytail: full-table scan; push predicates down as
			-- PS_CRITERIONs (see `search_by_criterion`) if tables grow.
		local
			l_matches: RESOURCE_HASH_TABLE [INTEGER, V]
			l_cursor: TABLE_ITERATION_CURSOR [V, INTEGER]
		do
			create l_matches.make (table_name + "_search")
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

	search_by_criterion (a_query: PS_CRITERION): TABLE_ITERATION_CURSOR [V, INTEGER]
			-- All rows matching `a_query`, executed by the database.
		local
			l_query: PS_QUERY [V]
		do
			create l_query.make
			l_query.set_criterion (a_query)
			proxy.execute_query (l_query)
			create {RESTLY_TABLE_CURSOR [V]} Result.make (l_query)
		end

feature -- Extension

	extend_new (a_v: V; a_request_id: HASHABLE)
			-- <Precursor>
			-- Backends that mint ids (relational managed types) demand
			-- id 0 on insert and write the minted key back into `a_v`;
			-- for the rest (generic layout) the resource mints first.
			-- Recording `a_v.id` after `insert` serves both.
		do
			if not extend_requests.has_key (a_request_id) then
				if not mints_ids then
					a_v.id := fresh_key (a_v)
				end
				insert (a_v)
				extend_requests.extend (a_v.id, a_request_id)
			end
		end

feature {RESTLY_PROTOCOL} -- Key minting

	fresh_key (a_v: V): INTEGER
			-- <Precursor>: one past the highest row id.
		do
			Result := highest_id + 1
		end

feature -- Listing

	new_cursor: TABLE_ITERATION_CURSOR [V, INTEGER]
			-- <Precursor>
			-- Streams the rows of a criterion-less query.
		local
			l_query: PS_QUERY [V]
		do
			create l_query.make
			proxy.execute_query (l_query)
			create {RESTLY_TABLE_CURSOR [V]} Result.make (l_query)
		end

	wipe_out
			-- <Precursor>
			-- All rows of V's table in a single transaction: atomic
			-- (all deleted or none), and scoped to this table — unlike
			-- ABEL's testing-only `wipe_out`, which empties every
			-- table of the repository.
		local
			l_query: PS_QUERY [V]
			l_cursor: ITERATION_CURSOR [V]
			l_transaction: PS_TRANSACTION
		do
			l_transaction := proxy.new_transaction
			create l_query.make
			l_transaction.execute_query (l_query)
			check repository_is_default: attached {PS_DEFAULT_REPOSITORY} proxy as l_repository then
				from
					l_cursor := l_query.new_cursor
				until
					l_cursor.after
				loop
					l_repository.delete (l_cursor.item, l_transaction.transaction)
					l_cursor.forth
				end
			end
			l_query.close
			l_transaction.commit
		end

feature {NONE} -- Implementation

	proxy: PS_REPOSITORY
			-- ABEL backend; owns all V <-> row conversion.
		do
			Result := table.repository
		end

	mints_ids: BOOLEAN
			-- Does the backend mint the primary key on insert, writing
			-- it back into the object? Derived: exactly the relational
			-- connector does (managed types, which demand id 0 and
			-- raise on any other value); the generic layout stores
			-- `id` as an ordinary attribute.
		do
			Result := attached {PS_DEFAULT_REPOSITORY} proxy as l_repository
				and then attached {PS_RELATIONAL_CONNECTOR} l_repository.connector
		end

	table: RESTLY_TABLE_HANDLE
			-- Handle into the owning database; keeps it alive.

	criterion_factory: PS_CRITERION_FACTORY
			-- Factory for row-id criteria.
		attribute
			create Result
		end

	key_criterion (k: INTEGER): PS_CRITERION
			-- Criterion selecting the row with id `k`.
		do
			Result := criterion_factory ("id", criterion_factory.equals, k)
		end

	table_name: STRING
			-- Relational table storing V: the type name lowercased,
			-- matching ABEL's own naming.
		do
			Result := ({V}).name.to_string_8.as_lower
				-- TYPE.name carries the attachment mark ("!SAMPLE_ROW").
			Result.prune_all ('!')
		end

	highest_id: INTEGER
			-- Largest id currently stored.
			-- ponytail: O(n) scan per POST; a MAX criterion if tables grow large.
		local
			l_query: PS_QUERY [V]
		do
			create l_query.make
			proxy.execute_query (l_query)
			across l_query as ic loop
				Result := Result.max (ic.id)
			end
			l_query.close
		end

	executed_key_query (k: INTEGER): PS_QUERY [V]
			-- Fresh executed query for row id `k`; caller closes it.
		do
			create Result.make
			Result.set_criterion (key_criterion (k))
			proxy.execute_query (Result)
		end

	insert (a_v: V)
			-- Insert `a_v` in its own transaction; ABEL writes the
			-- minted id back into `a_v`.
		local
			l_transaction: PS_TRANSACTION
		do
			l_transaction := proxy.new_transaction
			l_transaction.insert (a_v)
			l_transaction.commit
		end


end
