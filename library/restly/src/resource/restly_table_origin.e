note
	description: "[
		Origin: one relational table as the authoritative RESTLY store
		of typed objects (nothing stands behind it).
		Keys are row ids; values are Vs, (de)serialized by ABEL.
		Identity is the table; serialization is never ours.
	]"

class
	RESTLY_TABLE_ORIGIN [V -> RESTLY_IDENTIFIABLE [INTEGER]]

inherit
	RESTLY_POSTABLE [INTEGER, V]
		redefine
			extend_new
		end

	RESTLY_SEARCHABLE [PS_CRITERION, INTEGER, V]

	RESTLY_LISTABLE [INTEGER, V]

	PS_ABEL_EXPORT
			-- Grants access to ABEL internals: {PS_DEFAULT_REPOSITORY}.delete
			-- and {PS_TRANSACTION}.transaction, needed because ABEL's public
			-- API only deletes via garbage collection, which the relational
			-- backend cannot support (root status is not persisted in rows).

create
	make,
	make_with_repository

feature {NONE} -- Initialization

	make (a_table: RESTLY_DATABASE_TABLE)
			-- Store backed by ABEL repository reached through `a_table`.
		do
			table := a_table
		end

	make_with_repository (a_repository: PS_REPOSITORY)
			-- Store backed by ABEL repository `a_repository`.
			-- V must be a managed type of the factory that built the
			-- repository (manage ({V}, "id")) and flat: no references
			-- to other persisted objects.
		do
			internal_repository := a_repository
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
				l_cursor.item.set_id (k)
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

	search (a_query: PS_CRITERION): TABLE_ITERATION_CURSOR [V, INTEGER]
			-- <Precursor>
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
			-- The database mints the id and ABEL writes it back into
			-- `a_v`; record that id instead of pre-computing `fresh_key`.
		do
			if not extend_requests.has_key (a_request_id) then
				insert (a_v)
				extend_requests.extend (a_v.id, a_request_id)
			end
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

	count: INTEGER
			-- <Precursor>
			-- SELECT COUNT(*); no row ever travels.
		local
			l_transaction: PS_TRANSACTION
			l_connection: PS_SQL_CONNECTION
		do
			l_transaction := proxy.new_transaction
			check connector_is_relational: attached {PS_RDBMS_CONNECTOR} repository_connector as l_connector then
				l_connection := l_connector.get_connection (l_transaction.transaction)
				l_connection.execute_sql ("SELECT COUNT(*) FROM " + table_name)
				across l_connection as l_row loop
					Result := l_row [1].to_integer
				end
			end
			l_transaction.commit
		end

	wipe_out
			-- <Precursor>
			-- The relational backend deletes all rows of every managed table.
		do
			check repository_is_default: attached {PS_DEFAULT_REPOSITORY} proxy as l_repository then
				l_repository.wipe_out
			end
		end

feature -- Key minting

	fresh_key: INTEGER
			-- <Precursor>
			-- ABEL mints ids on insert; `extend_new` reads them back.
		do
			(create {EXCEPTIONS}).raise ("RESTLY_TABLE_ORIGIN.fresh_key must never be called; the database mints ids.")
		end

feature {NONE} -- Implementation

	proxy: PS_REPOSITORY
			-- ABEL backend; owns all V <-> row conversion.
		do
			if attached internal_repository as l_repository then
				Result := l_repository
			else
				check from_creation: attached table as l_table then
					Result := l_table.repository
				end
			end
		end

	internal_repository: detachable PS_REPOSITORY
			-- Set by `make_with_repository`; Void when using table handle.

	table: detachable RESTLY_DATABASE_TABLE
			-- Set by `make`; Void when using direct repository.

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

	repository_connector: PS_REPOSITORY_CONNECTOR
			-- Backend connector of `proxy`, reached through {PS_ABEL_EXPORT}.
		do
			check repository_is_default: attached {PS_DEFAULT_REPOSITORY} proxy as l_repository then
				Result := l_repository.connector
			end
		end

	table_name: STRING
			-- Relational table storing V: the type name lowercased,
			-- matching ABEL's own naming.
		do
			Result := ({V}).name.to_string_8.as_lower
				-- TYPE.name carries the attachment mark ("!SAMPLE_ROW").
			Result.prune_all ('!')
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
