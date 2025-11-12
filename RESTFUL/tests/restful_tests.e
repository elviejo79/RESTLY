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
		do
			first_file := ["first.txt", "Content of first file"]
			second_file := ["second.txt", "Content of second file"]
			dir := {DIRECTORY_RESOURCE}.make_and_register (file_path)
			dir.force (first_file.content, first_file.name)
			assert ("we must have the content stored", first_file.content ~ dir [first_file.name])
				-- dir.remove, should clean the first_file
			dir.remove (first_file.name)
			dir.force (second_file.content, second_file.name)
			assert ("we must have the content stored", second_file.content ~ dir [second_file.name])
				-- dir.remove, should clean the second_file
			dir.remove (second_file.name)
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

	test_github_client
		local
			gh_client: GITHUB_CLIENT
		do
			create gh_client.make
			assert ("if it reached this point it worked", True)
		end

	test_http_github_client
		local
			gh: API_RESOURCE
			result_from_api, jag_repos: STRING
		do
			create gh.make_with_url ("https://api.github.com")
			result_from_api := gh ["/orgs/dotnet/repos"]

			assert ("the call to the api worked! and is not empty", not result_from_api.is_empty)

			jag_repos := gh ["/orgs/jagacademy/repos"]
			assert ("jag repos is not empty", not jag_repos.is_empty)
			assert ("jag_repos is different from previous call", jag_repos /= result_from_api)
		end

feature -- Motivating Example Tests

	test_store_github_locally
		local
			gh: API_RESOURCE
			dir, other_dir: DIRECTORY_RESOURCE
			dotnet_repos: STRING
		do
			create gh.make_with_url ("https://api.github.com")
			dotnet_repos := gh ["/orgs/dotnet/repos"]

			assert ("the call to the api worked! and is not empty", not dotnet_repos.is_empty)

			dir := {DIRECTORY_RESOURCE}.make_and_register (file_path)
			dir ["dotnet.json"] := dotnet_repos
			assert ("the text was stored", dotnet_repos ~ dir ["dotnet.json"])

			other_dir := {DIRECTORY_RESOURCE}.make_and_register (file_path)
			assert ("other_dir has the same text", dotnet_repos ~ other_dir ["dotnet.json"])

			dir ["jagcoop.json"] := gh ["/orgs/jagcoop/repos"]
			assert ("connecting two a remote_resource with a local_one", other_dir ["jagcoop.json"] ~ dir ["jagcoop.json"])
		end

	test_short_github_locally
		local
			gh: API_RESOURCE
			dir, other_dir: DIRECTORY_RESOURCE
		do
			gh := {API_RESOURCE}.make_and_register ("https://api.github.com")
			dir := {DIRECTORY_RESOURCE}.make_and_register (file_path)

			dir ["jagcoop.json"] := gh ["/orgs/jagcoop/repos"]

			other_dir := {DIRECTORY_RESOURCE}.make_and_register (file_path)
			assert ("connecting to a remote_resource with a local_one", other_dir ["jagcoop.json"] ~ dir ["jagcoop.json"])
		end

feature -- Test values

	first: STRING = "1st string"
	second: STRING = "2nd string"
	third: STRING = "3rd string"

	url_com: URL
		attribute
			create Result.make_from_string ("http://www.example.com")
		end

	url_org: URL
		attribute
			create Result.make_from_string ("http://www.example.org")
		end

	file_path: URL
		attribute
			create Result.make_from_string ("file:///home/agarciafdz/exp_resources")
		end

end
