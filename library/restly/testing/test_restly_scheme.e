note
	description: "Tests for {RESTLY_SCHEME} registry and {RESTLY_SQLITE} wiring."

class
	TEST_RESTLY_SCHEME

inherit
	EQA_TEST_SET
		redefine
			on_clean
		end

feature {NONE} -- Fixtures

	db_file: STRING
			-- Database file unique to this test.
		attribute
			Result := "restly_scheme_" + environment.item_not_empty (Test_name_key, asserter).to_string_8 + ".db"
		end

	bootstrap_sample_schema (a_file: STRING)
			-- Create the sample_row table in `a_file`.
		local
			l_file: RAW_FILE
			l_db: SQLITE_DATABASE
		do
			across <<"", "-journal", "-wal", "-shm">> as suffix loop
				create l_file.make_with_name (a_file + suffix)
				if l_file.exists then
					l_file.delete
				end
			end
			create l_db.make_create_read_write (a_file)
			;(create {SQLITE_MODIFY_STATEMENT}.make ("CREATE TABLE sample_row (id INTEGER PRIMARY KEY AUTOINCREMENT, amount INTEGER);", l_db)).execute
			l_db.close
		end

	on_clean
			-- <Precursor>
		local
			l_file: RAW_FILE
		do
			across <<"", "-journal", "-wal", "-shm">> as suffix loop
				create l_file.make_with_name (db_file + suffix)
				if l_file.exists then
					l_file.delete
				end
			end
		end

feature -- Tests

	test_sqlite_same_file_yields_same_instance
			-- Same file string returns the identical {RESTLY_SQLITE}.
		do
			assert ("same instance", {RESTLY_SCHEME}.sqlite (db_file) = {RESTLY_SCHEME}.sqlite (db_file))
		end

	test_sqlite_different_files_yield_different_instances
			-- Different file strings return different instances.
		do
			assert ("different", {RESTLY_SCHEME}.sqlite ("a.db") /= {RESTLY_SCHEME}.sqlite ("b.db"))
		end

	test_file_same_directory_yields_same_instance
			-- Same directory string returns the identical {RESTLY_DIRECTORY}.
		do
			assert ("same instance", {RESTLY_SCHEME}.file ("/tmp/restly_test") = {RESTLY_SCHEME}.file ("/tmp/restly_test"))
		end

	test_file_different_directories_yield_different_instances
			-- Different directory strings return different instances.
		do
			assert ("different", {RESTLY_SCHEME}.file ("/tmp/restly_a") /= {RESTLY_SCHEME}.file ("/tmp/restly_b"))
		end

	test_end_to_end_roundtrip
			-- Full path: scheme -> sqlite -> table handle -> table_origin -> insert + read.
		local
			l_table: RESTLY_TABLE_ORIGIN [SAMPLE_ROW]
			l_row: SAMPLE_ROW
			l_key: INTEGER
		do
			bootstrap_sample_schema (db_file)
			create l_table.make ({RESTLY_SCHEME}.sqlite (db_file) / {SAMPLE_ROW})
			create l_row.make (42)
			l_table.extend_new (l_row, "req-1")
			l_key := l_table.extend_requests [{STRING} "req-1"]
			assert ("round-trips", l_table [l_key].amount = 42)
		end

end
