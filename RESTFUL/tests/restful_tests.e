note
	description: "Consolidated test class containing all RESTFUL library tests"
	author: "RESTFUL Team"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	RESTFUL_TESTS

inherit
	EQA_TEST_SET

feature -- REST_TABLE Tests

	test_assignment
		local
			tbl: REST_TABLE [STRING]
		do
			create tbl.make (3)
			tbl ["/sub/dir"] := first
			assert ("value was stored", first = tbl ["/sub/dir"])
			tbl ["/another"] := second
			tbl ["/sub/dir"] := third
			assert ("value was replaced", third = tbl ["/sub/dir"])
		end

	test_resource_table
		local
			tbl, other, different: RESOURCE_TABLE [STRING]
		do
			tbl := {RESOURCE_TABLE [STRING]}.make_and_register (url_com)
			other := {RESOURCE_TABLE [STRING]}.make_and_register (url_com)
			tbl ["\sub\dir"] := first
			assert ("other and tbl must point to *exactly* the same resource", first = other ["\sub\dir"])
			different := {RESOURCE_TABLE [STRING]}.make_and_register (url_org)
			different ["\sub\dir"] := first
			assert ("resources should be different, even if values are identical", tbl /~ different and tbl ["\sub\dir"] = different ["\sub\dir"])
		end

feature -- DIRECTORY_RESOURCE Tests

	test_directory
		local
			first_file, second_file: TUPLE [name: STRING; content: STRING]
			dir, other, different: DIRECTORY_RESOURCE
			first_key, second_key: PATH
		do
			first_file := ["first.txt", "Content of first file"]
			second_file := ["second.txt", "Content of second file"]
			create first_key.make_from_string (first_file.name)
			create second_key.make_from_string (second_file.name)
			dir := {DIRECTORY_RESOURCE}.make_and_register (file_path)
			dir.force (first_file.content, first_key)
			assert ("we must have the content stored", first_file.content ~ dir [first_key])
				-- dir.remove, should clean the first_file
			dir.remove (first_key)
			dir.force (second_file.content, second_key)
			assert ("we must have the content stored", second_file.content ~ dir [second_key])
				-- dir.remove, should clean the second_file
			dir.remove (second_key)
		end

feature -- DNS Tests

	test_dns
		local
			res, other, different: RESOURCE
		do
			res := {RESOURCE}.make_and_register (url_com)
			other := {RESOURCE}.make_and_register (url_com)
			assert ("res and other should be equivalent", res ~ other)
			assert ("res and other should be identical", res = other)

			different := {RESOURCE}.make_and_register (url_org)
			assert ("res and different should not be equivalent", not (res ~ different))
			assert ("res and different should be different", not (res = different))
		end

feature -- GitHub Tests

--	test_github_client
--		local
--			gh_client: GITHUB_CLIENT
--		do
--			create gh_client.make
--			assert ("if it reached this point it worked", True)
--		end

--	test_http_github_client
--		local
--			gh: API_RESOURCE
--			result_from_api, jag_repos: STRING
--			gh_url: URL
--		do
--			create gh_url.make_from_string ("https://api.github.com")
--			create gh.make_with_url (gh_url)
--			result_from_api := gh ["/orgs/dotnet/repos"]

--			assert ("the call to the api worked! and is not empty", not result_from_api.is_empty)

--			jag_repos := gh ["/orgs/jagacademy/repos"]
--			assert ("jag repos is not empty", not jag_repos.is_empty)
--			assert ("jag_repos is different from previous call", jag_repos /= result_from_api)
--		end
feature -- Motivating Example Tests

--	test_store_github_locally
--		local
--			gh: API_RESOURCE
--			dir, other_dir: DIRECTORY_RESOURCE
--			dotnet_repos: STRING
--			gh_url: URL
--		do
--			create gh_url.make_from_string ("https://api.github.com")
--			create gh.make_with_url (gh_url)
--			dotnet_repos := gh ["/orgs/dotnet/repos"]

--			assert ("the call to the api worked! and is not empty", not dotnet_repos.is_empty)

--			dir := {DIRECTORY_RESOURCE}.make_and_register (file_path)
--			dir ["dotnet.json"] := dotnet_repos
--			assert ("the text was stored", dotnet_repos ~ dir ["dotnet.json"])

--			other_dir := {DIRECTORY_RESOURCE}.make_and_register (file_path)
--			assert ("other_dir has the same text", dotnet_repos ~ other_dir ["dotnet.json"])

--			dir ["jagcoop.json"] := gh ["/orgs/jagcoop/repos"]
--			assert ("connecting two a remote_resource with a local_one", other_dir ["jagcoop.json"] ~ dir ["jagcoop.json"])
--		end

--	test_short_github_locally
--		local
--			gh: API_RESOURCE
--			dir, other_dir: DIRECTORY_RESOURCE
--			gh_url: URL
--		do
--			create gh_url.make_from_string ("https://api.github.com")
--			gh := {API_RESOURCE}.make_and_register (gh_url)
--			dir := {DIRECTORY_RESOURCE}.make_and_register (file_path)

--			dir ["jagcoop.json"] := gh ["/orgs/jagcoop/repos"]

--			other_dir := {DIRECTORY_RESOURCE}.make_and_register (file_path)
--			assert ("connecting to a remote_resource with a local_one", other_dir ["jagcoop.json"] ~ dir ["jagcoop.json"])
--		end
feature -- ENV_SCHEME

	test_has_key_existing_var
			-- Test has_key with real environment variables
		local
			env: ENV_SCHEME
			path_key: PATH
		do
			create env.make (env_url)
			create path_key.make_from_string ("PATH")
			assert ("PATH environment variable should exist", env.has_key (path_key))
		end

	test_has_key_nonexistent_var
			-- Test has_key with non-existent variable
		local
			env: ENV_SCHEME
			fake_key: PATH
		do
			create env.make (env_url)
			create fake_key.make_from_string ("NONEXISTENT_VAR_XYZ_12345")
			assert ("Non-existent variable should not exist", not env.has_key (fake_key))
		end

	test_item_existing_var
			-- Test retrieving actual environment variable values
		local
			env: ENV_SCHEME
			path_key: PATH
			path_value: STRING
		do
			create env.make (env_url)
			create path_key.make_from_string ("PATH")
			path_value := env.item (path_key)
			assert ("PATH value should not be empty", not path_value.is_empty)
			assert ("PATH value should contain path separators", path_value.has (':') or path_value.has (';'))
		end

	test_force_new_variable
			-- Test creating a new environment variable
		local
			env: ENV_SCHEME
			test_key: PATH
			test_value: STRING
		do
			create env.make (env_url)
			create test_key.make_from_string ("TEST_NEW_VAR_12345")
			test_value := "test_value_new"

			env.force (test_value, test_key)
			assert ("New variable should exist after force", env.has_key (test_key))
			assert ("New variable should have correct value", env.item (test_key) ~ test_value)
		end

	test_keys_returns_environment
			-- Test that keys feature returns environment variables
		local
			env: ENV_SCHEME
			env_keys: HASH_TABLE [STRING_32, STRING_32]
		do
			create env.make (env_url)
			env_keys := env.keys
			assert ("Environment keys should not be empty", env_keys.count > 0)
			assert ("Environment should contain PATH", env_keys.has ("PATH") or env_keys.has ("Path"))
		end

	test_empty_string_value
			-- Test storing an emty string should throw an exception
		local
			env: ENV_SCHEME
			test_key: PATH
			empty_value: STRING
			exception_caught: BOOLEAN
		do
			if not exception_caught then
				create env.make (env_url)
				create test_key.make_from_string ("TEST_EMPTY_VAR_12345")
				create empty_value.make_empty

				env.force (empty_value, test_key)
				assert ("Should have thrown check violation", False)
			end
		rescue
			exception_caught := True
			retry
		end

	test_case_sensitivity
			-- Test environment variable name case sensitivity (OS-dependent)
		local
			env: ENV_SCHEME
			lower_key, upper_key: PATH
			test_value: STRING
		do
			create env.make (env_url)
			create lower_key.make_from_string ("test_case_var_12345")
			create upper_key.make_from_string ("TEST_CASE_VAR_12345")
			test_value := "case_test_value"

			env.force (test_value, lower_key)

				-- On Unix: case-sensitive (different keys)
				-- On Windows: case-insensitive (same key)
			if env.has_key (upper_key) then
				assert ("On case-insensitive OS, upper and lower should access same var",
					env.item (upper_key) ~ test_value)
			else
				assert ("On case-sensitive OS, upper key should not exist",
					not env.has_key (upper_key))
			end
		end

	test_concurrent_modifications
			-- Test that multiple ENV_SCHEME instances share process environment
		local
			env1, env2: ENV_SCHEME
			test_key: PATH
			test_value: STRING
		do
			create env1.make (env_url)
			create env2.make (env_url)
			create test_key.make_from_string ("TEST_SHARED_VAR_12345")
			test_value := "shared_value"

			env1.force (test_value, test_key)
			assert ("Value set in env1 should be visible in env2", env2.has_key (test_key))
			assert ("Value from env1 should match in env2", env2.item (test_key) ~ test_value)
		end

feature -- FILE_SCHEME

	test_make_existing_directory
			-- Test creating FILE_SCHEME with existing directory
		local
			file_scheme: FILE_SCHEME
		do
			create file_scheme.make (file_path)
			assert ("File scheme should be created successfully", file_scheme /= Void)
			assert ("Base URI should be set", file_scheme.base_uri ~ file_path)
		end

	test_make_nonexistent_directory_fails
			-- Test that creating FILE_SCHEME with non-existent directory fails
		local
			file_scheme: FILE_SCHEME
			exception_caught: BOOLEAN
		do
			if not exception_caught then
				create file_scheme.make (nonexistent_file_path)
				assert ("Should have thrown postcondition violation", False)
			end
		rescue
			exception_caught := True
			retry
		end

	test_has_key_existing_file
			-- Test has_key returns true for existing file
		local
			file_scheme: FILE_SCHEME
			test_key: PATH
		do
			create file_scheme.make (file_path)
			create test_key.make_from_string ("test_file.txt")

				-- Create the test file first
			file_scheme.force ("test content", test_key)

			assert ("File should exist", file_scheme.has_key (test_key))

				-- Cleanup
			file_scheme.remove (test_key)
		end

	test_item_existing_file
			-- Test retrieving content from existing file
		local
			file_scheme: FILE_SCHEME
			test_key: PATH
			test_content, retrieved_content: STRING
		do
			create file_scheme.make (file_path)
			create test_key.make_from_string ("test_read_file.txt")
			test_content := "This is test content for reading"

				-- Create the test file first
			file_scheme.force (test_content, test_key)

			retrieved_content := file_scheme.item (test_key)
			assert ("Retrieved content should match stored content", retrieved_content ~ test_content)

				-- Cleanup
			file_scheme.remove (test_key)
		end

	test_force_new_file
			-- Test creating new file with explicit filename
		local
			file_scheme: FILE_SCHEME
			test_key: PATH
			test_content: STRING
		do
			create file_scheme.make (file_path)
			create test_key.make_from_string ("new_file.txt")
			test_content := "New file content"

			file_scheme.force (test_content, test_key)

			assert ("File should exist after force", file_scheme.has_key (test_key))
			assert ("Content should match", file_scheme.item (test_key) ~ test_content)
			assert ("Last inserted key should be set", file_scheme.last_inserted_key ~ test_key)

				-- Cleanup
			file_scheme.remove (test_key)
		end

	test_force_overwrite_file
			-- Test overwriting existing file content
		local
			file_scheme: FILE_SCHEME
			test_key: PATH
			original_content, new_content: STRING
		do
			create file_scheme.make (file_path)
			create test_key.make_from_string ("overwrite_test.txt")
			original_content := "Original content"
			new_content := "New overwritten content"

				-- Create initial file
			file_scheme.force (original_content, test_key)
			assert ("Original content stored", file_scheme.item (test_key) ~ original_content)

				-- Overwrite
			file_scheme.force (new_content, test_key)
			assert ("Content should be overwritten", file_scheme.item (test_key) ~ new_content)
			assert ("Content should not be original", not (file_scheme.item (test_key) ~ original_content))

				-- Cleanup
			file_scheme.remove (test_key)
		end

	test_collection_extend
			-- Test creating file without specifying filename (uses SHA256)
		local
			file_scheme: FILE_SCHEME
			test_content: STRING
			generated_key: PATH
		do
			create file_scheme.make (file_path)
			test_content := "Content for auto-generated filename"

			file_scheme.collection_extend (test_content)

			generated_key := file_scheme.last_inserted_key
			assert ("Last inserted key should be set", generated_key /= Void)
			assert ("File should exist with generated key", file_scheme.has_key (generated_key))
			assert ("Content should match", file_scheme.item (generated_key) ~ test_content)

				-- Cleanup
			file_scheme.remove (generated_key)
		end

	test_remove_file
			-- Test deleting file
		local
			file_scheme: FILE_SCHEME
			test_key: PATH
			test_content: STRING
		do
			create file_scheme.make (file_path)
			create test_key.make_from_string ("file_to_remove.txt")
			test_content := "This file will be removed"

				-- Create file
			file_scheme.force (test_content, test_key)
			assert ("File should exist before removal", file_scheme.has_key (test_key))

				-- Remove file
			file_scheme.remove (test_key)
			assert ("File should not exist after removal", not file_scheme.has_key (test_key))
		end

	test_keys_returns_files
			-- Test that keys lists directory entries
		local
			file_scheme: FILE_SCHEME
			test_key1, test_key2: PATH
			file_keys: ARRAYED_LIST [PATH]
		do
			create file_scheme.make (file_path)
			create test_key1.make_from_string ("keys_test1.txt")
			create test_key2.make_from_string ("keys_test2.txt")

				-- Create test files
			file_scheme.force ("content1", test_key1)
			file_scheme.force ("content2", test_key2)

			file_keys := file_scheme.keys
			assert ("Keys should not be empty", file_keys.count >= 2)

				-- Cleanup
			file_scheme.remove (test_key1)
			file_scheme.remove (test_key2)
		end

	test_multiple_instances_same_path
			-- Test multiple FILE_SCHEME instances with same base_uri access same files
		local
			file_scheme1, file_scheme2: FILE_SCHEME
			test_key: PATH
			test_content: STRING
		do
			create file_scheme1.make (file_path)
			create file_scheme2.make (file_path)
			create test_key.make_from_string ("shared_file.txt")
			test_content := "Shared content"

				-- Write with first instance
			file_scheme1.force (test_content, test_key)

				-- Read with second instance
			assert ("Second instance should see the file", file_scheme2.has_key (test_key))
			assert ("Second instance should read same content", file_scheme2.item (test_key) ~ test_content)

				-- Cleanup
			file_scheme1.remove (test_key)
		end

	test_empty_file_content
			-- Test storing and retrieving empty string
		local
			file_scheme: FILE_SCHEME
			test_key: PATH
			empty_content: STRING
		do
			create file_scheme.make (file_path)
			create test_key.make_from_string ("empty_file.txt")
			create empty_content.make_empty

			file_scheme.force (empty_content, test_key)
			assert ("Empty file should exist", file_scheme.has_key (test_key))
			assert ("Retrieved content should be empty", file_scheme.item (test_key).is_empty)

				-- Cleanup
			file_scheme.remove (test_key)
		end

feature -- Test values

	first: STRING = "1st string"
	second: STRING = "2nd string"
	third: STRING = "3rd string"

	url_com: URI
		attribute
			create Result.make_from_string ("http://www.example.com")
		end

	url_org: URI
		attribute
			create Result.make_from_string ("http://www.example.org")
		end

	file_path: FILE_URL
		attribute
			create Result.make_from_string ("file:///home/agarciafdz/exp_resources")
		end

	env_url: URI
		attribute
			create Result.make_from_string ("env://")
		end

	nonexistent_file_path: FILE_URL
		attribute
			create Result.make_from_string ("file:///home/agarciafdz/nonexistent_test_directory_12345")
		end

end
