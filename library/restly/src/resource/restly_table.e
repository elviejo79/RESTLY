note
	description: "[
		One relational table as a RESTLY store of typed objects.
		Keys are row ids; values are Vs, (de)serialized by ABEL.
		Identity is the table; serialization is never ours.
	]"

class
	RESTLY_TABLE [V -> ANY]

inherit
	RESTLY_POSTABLE [INTEGER, V]
		redefine
			extend_new
		end

	RESTLY_SEARCHABLE [PS_CRITERION, V]

create
	make_with_repository

feature {NONE} -- Initialization

	make_with_repository (a_repository: PS_REPOSITORY)
			-- Store backed by ABEL repository `a_repository`.
			-- V must be a managed type of the factory that built the
			-- repository (manage ({V}, "id")) and flat: no references
			-- to other persisted objects.
		do
			proxy := a_repository
			create criterion_factory
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
				set_id (l_cursor.item, k)
				l_transaction.update (l_cursor.item)
			end
			l_query.close
			l_transaction.commit
		end

	remove (k: INTEGER)
			-- Delete row `k` (ABEL deletes by unrooting plus garbage collection).
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
			if not l_cursor.after and then l_transaction.is_root (l_cursor.item) then
				l_transaction.unmark_root (l_cursor.item)
			end
			l_query.close
			l_transaction.commit
			proxy.collect_garbage
		end

	search (a_query: PS_CRITERION): ITERABLE [V]
			-- <Precursor>
		local
			l_query: PS_QUERY [V]
			l_matches: V_LINKED_LIST [V]
		do
			create l_query.make
			l_query.set_criterion (a_query)
			proxy.execute_query (l_query)
			create l_matches
			across l_query as v loop
				l_matches.extend_back (v)
			end
			l_query.close
			Result := l_matches
		end

feature -- Extension

	extend_new (a_v: V; a_request_id: HASHABLE)
			-- <Precursor>
			-- The database mints the id and ABEL writes it back into
			-- `a_v`; record that id instead of pre-computing `fresh_key`.
		do
			if not extend_requests.has_key (a_request_id) then
				insert (a_v)
				extend_requests.extend (id_of (a_v), a_request_id)
			end
		end

feature -- Key minting

	fresh_key: INTEGER
			-- <Precursor>
			-- ponytail: O(n) max-scan, advisory only — the database mints
			-- the real id on insert; `extend_new` never calls this.
		local
			l_query: PS_QUERY [V]
		do
			create l_query.make
			proxy.execute_query (l_query)
			across l_query as v loop
				Result := Result.max (id_of (v))
			end
			l_query.close
			Result := Result + 1
		end

feature {NONE} -- Implementation

	proxy: PS_REPOSITORY
			-- ABEL backend; owns all V <-> row conversion.

	criterion_factory: PS_CRITERION_FACTORY
			-- Factory for row-id criteria.

	key_criterion (k: INTEGER): PS_CRITERION
			-- Criterion selecting the row with id `k`.
		do
			Result := criterion_factory ("id", criterion_factory.equals, k)
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

	id_of (a_v: V): INTEGER
			-- Value of `a_v`'s integer `id` field (the managed primary key).
		local
			l_reflected: REFLECTED_REFERENCE_OBJECT
		do
			create l_reflected.make (a_v)
			across 1 |..| l_reflected.field_count as i loop
				if l_reflected.field_name (i).same_string ("id") then
					Result := l_reflected.integer_32_field (i)
				end
			end
		end

	set_id (a_v: V; a_id: INTEGER)
			-- Write `a_id` into `a_v`'s integer `id` field.
		local
			l_reflected: REFLECTED_REFERENCE_OBJECT
		do
			create l_reflected.make (a_v)
			across 1 |..| l_reflected.field_count as i loop
				if l_reflected.field_name (i).same_string ("id") then
					l_reflected.set_integer_32_field (i, a_id)
				end
			end
		end

end
