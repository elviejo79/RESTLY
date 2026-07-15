note
	description: "Tests for RESTLY_DIRECTORY, RESTLY_FILE, RESTLY_FILE_NODE."

class
	TEST_RESTLY_DIRECTORY

inherit
	EQA_TEST_SET
		redefine
			on_prepare, on_clean
		end

feature {NONE} -- Fixtures

	sandbox_path: STRING
			-- Sandbox unique to this test.
			-- The executor runs tests in several concurrent evaluator
			-- processes; a shared path lets one test's `on_prepare` wipe
			-- another test's files mid-flight.
		attribute
			Result := "/tmp/restly_test_dir_" + environment.item_not_empty (Test_name_key, asserter).to_string_8
		end

	dir: RESTLY_DIRECTORY
		attribute
			Result := {RESTLY_SCHEME}.file (sandbox_path)
		end

feature {NONE} -- Setup / teardown

	on_prepare
			-- <Precursor>
		local
			d: DIRECTORY
		do
			create d.make_with_name (sandbox_path)
			if d.exists then
				d.recursive_delete
			end
			d.recursive_create_dir
		end

	on_clean
			-- <Precursor>
		local
			d: DIRECTORY
		do
			create d.make_with_name (sandbox_path)
			if d.exists then
				d.recursive_delete
			end
		end

feature {NONE} -- Helpers

	ensure_subdirectory (a_name: STRING)
			-- Create `a_name` subdirectory inside the sandbox.
		local
			d: DIRECTORY
		do
			create d.make_with_name (sandbox_path + "/" + a_name)
			if not d.exists then
				d.recursive_create_dir
			end
		end

feature -- Core verb tests

	test_force_then_item_roundtrip
		do
			dir ["/a.txt"] := "hello"
			assert ("roundtrip", dir ["/a.txt"] ~ "hello")
		end

	test_has_key_false_for_missing
		do
			assert ("missing key", not dir.has_key ("/nope.txt"))
		end

	test_has_key_true_after_force
		do
			dir ["/a.txt"] := "x"
			assert ("key present", dir.has_key ("/a.txt"))
		end

	test_has_key_false_for_subdirectory
		do
			ensure_subdirectory ("sub")
			assert ("subdir is not a file key", not dir.has_key ("/sub"))
		end

	test_extend_creates_fresh_key
		do
			dir.extend ("v", "/new.txt")
			assert ("has_key after extend", dir.has_key ("/new.txt"))
			assert ("roundtrip", dir ["/new.txt"] ~ "v")
		end

	test_put_overwrites_existing
		do
			dir ["/a.txt"] := "v1"
			dir.put ("v2", "/a.txt")
			assert ("overwritten", dir ["/a.txt"] ~ "v2")
		end

	test_remove_deletes
		do
			dir ["/a.txt"] := "x"
			dir.remove ("/a.txt")
			assert ("gone", not dir.has_key ("/a.txt"))
		end

feature -- Navigation tests

	test_subdirectory_read_through
		do
			ensure_subdirectory ("sub")
			;(dir / "sub").force ("x", "/f.txt")
			assert ("read through subdir", dir ["/sub/f.txt"] ~ "x")
		end

	test_node_dispatches_on_kind
		do
			dir ["/a.txt"] := "x"
			ensure_subdirectory ("sub")
			assert ("file node", attached {RESTLY_FILE} dir.node ("/a.txt"))
			assert ("dir node", attached {RESTLY_DIRECTORY} dir.node ("/sub"))
		end

	test_slash_alias_equals_subdirectory
		do
			ensure_subdirectory ("sub")
			assert ("alias matches query", (dir / "sub") ~ dir.subdirectory ("sub"))
		end

feature -- Traversal tests

	test_entries_yields_both_kinds
		local
			file_count: INTEGER
			dir_count: INTEGER
		do
			dir ["/a.txt"] := "x"
			ensure_subdirectory ("sub")
			across dir.entries as n loop
				if attached {RESTLY_FILE} n then
					file_count := file_count + 1
				elseif attached {RESTLY_DIRECTORY} n then
					dir_count := dir_count + 1
				end
			end
			assert ("one file node", file_count = 1)
			assert ("one dir node", dir_count = 1)
		end

	test_entries_file_node_reads_contents
		do
			dir ["/a.txt"] := "hello"
			across dir.entries as n loop
				if attached {RESTLY_FILE} n as f then
					assert ("contents", f.item ~ "hello")
					assert ("name", f.name.same_string ("a.txt"))
				end
			end
		end

feature -- RESTLY_FILE leaf tests

	test_restly_file_leaf_lifecycle
		local
			f: RESTLY_FILE
		do
			create f.make_with_path (create {PATH}.make_from_string (sandbox_path + "/leaf.txt"))

			assert ("not exists before put", not f.exists)
			f.put ("data")
			assert ("exists after put", f.exists)
			assert ("item roundtrip", f.item ~ "data")
			f.remove
			assert ("not exists after remove", not f.exists)
		end

	test_empty_file_item_is_empty_string
		do
			dir ["/e.txt"] := ""
			assert ("empty item", dir ["/e.txt"].is_empty)
		end

	test_binary_bytes_roundtrip
		local
			binary: STRING
			i: INTEGER
		do
			create binary.make (256)
			from i := 0 until i > 255 loop
				binary.append_character (i.to_character_8)
				i := i + 1
			end
			dir ["/bin.dat"] := binary
			assert ("binary roundtrip", dir ["/bin.dat"] ~ binary)
		end

end
