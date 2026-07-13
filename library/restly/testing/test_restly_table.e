note
	description: "Tests for RESTLY_TABLE over a real SQLite database."

class
	TEST_RESTLY_TABLE

inherit
	EQA_TEST_SET
		redefine
			on_clean
		end

feature {NONE} -- Fixtures

	db_file: STRING
			-- Database file unique to this test.
			-- The executor runs tests in several concurrent evaluator
			-- processes; a shared file name lets one test delete the
			-- database out from under another's live connection.
		attribute
			Result := "restly_table_" + environment.item_not_empty (Test_name_key, asserter).to_string_8 + ".db"
		end

	repository: PS_REPOSITORY
			-- Repository over a fresh SQLite database file.
		local
			l_file: RAW_FILE
			l_db: SQLITE_DATABASE
			l_modify: SQLITE_MODIFY_STATEMENT
			l_factory: PS_SQLITE_RELATIONAL_REPOSITORY_FACTORY
		attribute
				-- A crashed evaluator process can leave a hot journal;
				-- next to a recreated database it makes SQLite refuse
				-- writes, so wipe the whole file family.
			across <<"", "-journal", "-wal", "-shm">> as suffix loop
				create l_file.make_with_name (db_file + suffix)
				if l_file.exists then
					l_file.delete
				end
			end
			create l_db.make_create_read_write (db_file)
			create l_modify.make ("CREATE TABLE sample_row (id INTEGER PRIMARY KEY AUTOINCREMENT, amount INTEGER);", l_db)
			l_modify.execute
			l_db.close
			create l_factory.make
			l_factory.set_database (db_file)
			l_factory.manage ({SAMPLE_ROW}, "id")
			Result := l_factory.new_repository
		end

	table: RESTLY_TABLE [SAMPLE_ROW]
			-- Fresh table over `repository`.
		attribute
			create Result.make_with_repository (repository)
		end

	on_clean
			-- <Precursor>
			-- Close the repository's SQLite connection.
		do
			repository.close
		end

	criterion_factory: PS_CRITERION_FACTORY
		attribute create Result end

feature -- Tests

	test_extend_new_stores_row
			-- After extend_new, the minted key is present, the row round-trips,
			-- and the id was written back into the inserted object.
		local
			l_table: RESTLY_TABLE [SAMPLE_ROW]
			l_row: SAMPLE_ROW
			l_key: INTEGER
		do
			l_table := table
			create l_row.make (42)
			l_table.extend_new (l_row, "req-1")
			l_key := l_table.extend_requests [{STRING} "req-1"]
			assert ("key present", l_table.has_key (l_key))
			assert ("row round-trips", l_table [l_key] ~ l_row)
			assert ("id written back", l_row.id = l_key)
		end

	test_search_filters_rows
			-- search returns exactly the rows matching the criterion.
		local
			l_table: RESTLY_TABLE [SAMPLE_ROW]
			l_count: INTEGER
		do
			l_table := table
			l_table.extend_new (create {SAMPLE_ROW}.make (10), "req-1")
			l_table.extend_new (create {SAMPLE_ROW}.make (20), "req-2")
			l_table.extend_new (create {SAMPLE_ROW}.make (30), "req-3")
			across l_table.search (criterion_factory ("amount", criterion_factory.greater, 15)) as row loop
				l_count := l_count + 1
				assert ("only matching rows", row.amount > 15)
			end
			assert ("two matches", l_count = 2)
		end

	test_put_updates_row
			-- put replaces the row's payload; the key imposes the id.
		local
			l_table: RESTLY_TABLE [SAMPLE_ROW]
			l_key: INTEGER
		do
			l_table := table
			l_table.extend_new (create {SAMPLE_ROW}.make (1), "req-1")
			l_key := l_table.extend_requests [{STRING} "req-1"]
			l_table.put (create {SAMPLE_ROW}.make (99), l_key)
			assert ("key still present", l_table.has_key (l_key))
			assert ("payload updated", l_table [l_key].amount = 99)
		end

	test_listing_streams_rows
			-- Iteration streams all rows, count matches, wipe_out empties.
		local
			l_table: RESTLY_TABLE [SAMPLE_ROW]
			l_total: INTEGER
		do
			l_table := table
			l_table.extend_new (create {SAMPLE_ROW}.make (10), "req-1")
			l_table.extend_new (create {SAMPLE_ROW}.make (20), "req-2")
			assert ("two rows", l_table.count = 2)
			across l_table as row loop
				l_total := l_total + row.amount
			end
			assert ("all rows listed", l_total = 30)
			l_table.wipe_out
			assert ("empty after wipe_out", l_table.count = 0)
		end

	test_front_delegates_key_minting
			-- extend_new over a POSTABLE store records the database-minted id;
			-- the front's own fresh_key (which raises) is never touched.
		local
			l_front: SAMPLE_TABLE_FRONT
			l_key: INTEGER
		do
			create l_front.make (table,
				create {RESTLY_IDENTITY_KEY_CONVERTER [INTEGER]},
				create {RESTLY_IDENTITY_CONVERTER [SAMPLE_ROW]})
			l_front.extend_new (create {SAMPLE_ROW}.make (5), "req-1")
			l_key := l_front.extend_requests [{STRING} "req-1"]
			assert ("front sees the row", l_front.has_key (l_key))
			assert ("payload round-trips", l_front [l_key].amount = 5)
		end

	test_remove_deletes_row
			-- After remove, the key is gone.
		local
			l_table: RESTLY_TABLE [SAMPLE_ROW]
			l_key: INTEGER
		do
			l_table := table
			l_table.extend_new (create {SAMPLE_ROW}.make (7), "req-1")
			l_key := l_table.extend_requests [{STRING} "req-1"]
			l_table.remove (l_key)
			assert ("key gone", not l_table.has_key (l_key))
		end

end
