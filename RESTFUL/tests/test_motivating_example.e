note
	description: "[
			Eiffel tests that can be executed by testing tool.
		]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TEST_MOTIVATING_EXAMPLE

inherit
	EQA_TEST_SET

feature -- Test routines

	test_store_github_locally
		local
			gh: API_RESOURCE
			dir, other_dir: DIRECTORY_RESOURCE
			dotnet_repos: STRING
		do
			create gh.make_with_url ("https://api.github.com")
				-- let's tryto get something from an API
			dotnet_repos := gh ["/orgs/dotnet/repos"]

			assert ("the call t othe api worked! and is not empty", not dotnet_repos.is_empty)

			dir := {DIRECTORY_RESOURCE}.make_and_register ("file:///home/agarciafdz/exp_resources")
			dir ["dotnet.json"] := dotnet_repos
			assert ("the text was stored", dotnet_repos ~ dir ["dotnet.json"])

				-- resources are unique in the app
			other_dir := {DIRECTORY_RESOURCE}.make_and_register ("file:///home/agarciafdz/exp_resources")
			assert ("other_dir has the same text", dotnet_repos ~ other_dir ["dotnet.json"])

				-- va a ser increíble si esto funciona:
			dir ["jagcoop.json"] := gh ["/orgs/jagcoop/repos"]
			assert ("connecting two a remote_resource with a local_one", other_dir ["jagcoop.json"] ~ dir ["jagcoop.json"])
		end

	test_short_github_locally
		local
			gh: API_RESOURCE
			dir, other_dir: DIRECTORY_RESOURCE
		do
			gh := {API_RESOURCE}.make_and_register ("https://api.github.com")
			dir := {DIRECTORY_RESOURCE}.make_and_register ("file:///home/agarciafdz/exp_resources")

				-- It's going to be unbeliveble, if this works
			dir ["jagcoop.json"] := gh ["/orgs/jagcoop/repos"]

				-- just to show that resources are unique to their URL
			other_dir := {DIRECTORY_RESOURCE}.make_and_register ("file:///home/agarciafdz/exp_resources")
			assert ("connecting tw5o a remote_resource with a local_one", other_dir ["jagcoop.json"] = dir ["jagcoop.json"])
		end

end

