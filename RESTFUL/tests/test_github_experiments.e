note
	description: "[
			Eiffel tests that can be executed by testing tool.
		]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TEST_GITHUB_EXPERIMENTS

inherit
	EQA_TEST_SET

feature -- Test routines

	test_github_client
		local
			gh_client: GITHUB_CLIENT
		do
			create gh_client.make

			assert ("if it reached this point it workke", True)
		end

	test_http_gituhb_client
	local
		gh : API_RESOURCE
		result_from_api,jag_repos : STRING
	do
		create gh.make_with_url("https://api.github.com")
		-- let's tryto get something from an API
		create result_from_api.make_empty
		result_from_api:=gh["/orgs/dotnet/repos"]

		assert("the call t othe api worked! and is not empty", not result_from_api.is_empty)

		-- now let's do another call

		jag_repos := gh["/orgs/jagacademy/repos"]
		assert("jag repos is not empty", not jag_repos.is_empty)
		assert("jag_repos is different from previous call", jag_repos /= result_from_api)

	end
end

