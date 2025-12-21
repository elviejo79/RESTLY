note
    description: "Project root class"
    author: "agarciafdz"
    date: "$Date$"
    revision: "$Revision$"

class
    GITHUB_CLIENT

create
    make

feature {NONE} -- Initialization

    make
            -- Run application.
        local
            l_repo: GITHUB_REPOSITORY
        do
            -- Simple test with hard-coded JSON
            l_repo := {GITHUB_REPOSITORY}.from_json (json_element)
            io.put_string ("Repository Name: " + l_repo.name + "%N")

            process_repositories
        end

    process_repositories
            -- Fetch and process repositories from GitHub API
        local
            http_client: DEFAULT_HTTP_CLIENT
             session: HTTP_CLIENT_SESSION      -- Add this for the session
            context: HTTP_CLIENT_REQUEST_CONTEXT
            response: HTTP_CLIENT_RESPONSE
            l_repo: GITHUB_REPOSITORY
            i: INTEGER
            json_parser: JSON_PARSER
            json_array: JSON_ARRAY
            json_object: PICO_JSON_OBJECT
        do
            -- Create HTTP client
            create http_client
   			session := http_client.new_session ("https://api.github.com")
   			session.set_timeout (10)
   			session.set_connect_timeout (30)
            -- Create request context
            create context.make
            context.set_credentials_required (False)

            -- Add headers to context
            context.add_header ("Accept", "application/vnd.github.v3+json")
            context.add_header ("User-Agent", "Eiffel Repository Reporter")

            -- Send request
            response := session.get ("/orgs/dotnet/repos", context)

            if response.status = 200 and then attached response.body as a_body then
                -- Parse JSON response
                create json_parser.make_with_string ( a_body )
                json_parser.parse_content

                if json_parser.is_valid and then attached {JSON_ARRAY} json_parser.parsed_json_value as json_repos then
                    io.put_string ("Found " + json_repos.count.out + " repositories%N")

                    from
                        i := 1
                    until
                        i > json_repos.count
                    loop
                        if attached {PICO_JSON_OBJECT} json_repos.i_th (i) as repo_json then
                            l_repo := {GITHUB_REPOSITORY}.from_json_object (repo_json)

                            io.put_string ("Name: " + l_repo.name + "%N")
                            io.put_string ("Homepage: " + l_repo.home_page + "%N")
                            io.put_string ("GitHub: " + l_repo.git_hub_homeurl + "%N")
                            io.put_string ("Description: " + l_repo.description + "%N")
                            io.put_string ("Watchers: " + l_repo.watchers.out + "%N")
                            io.put_string ("LastPush: " + l_repo.last_push + "%N")
                            io.put_string ("%N============%N")
                        end

                        i := i + 1
                    end
                end
            else
                io.put_string ("Error fetching repositories: " + response.status.out + " -  + response.error_message.out + %N")
            end

            -- Create and output a sample repository
            create l_repo.make
            l_repo.set_name ("Eiffel.Net7")
            l_repo.set_description ("Testing")
            l_repo.set_home_page ("http://example.com")

            io.put_string (l_repo.to_json + "%N")
        end

    json_element: STRING = "[
        {"id":4149293,"node_id":"MDEwOlJlcG9zaXRvcnk0MTQ5Mjkz","name":"cecil","full_name":"dotnet/cecil","private":false,"owner":{"login":"dotnet","id":9141961,"node_id":"MDEyOk9yZ2FuaXphdGlvbjkxNDE5NjE=","avatar_url":"https://avatars.githubusercontent.com/u/9141961?v=4","gravatar_id":"","url":"https://api.github.com/users/dotnet","html_url":"https://github.com/dotnet","followers_url":"https://api.github.com/users/dotnet/followers","following_url":"https://api.github.com/users/dotnet/following{/other_user}","gists_url":"https://api.github.com/users/dotnet/gists{/gist_id}","starred_url":"https://api.github.com/users/dotnet/starred{/owner}{/repo}","subscriptions_url":"https://api.github.com/users/dotnet/subscriptions","organizations_url":"https://api.github.com/users/dotnet/orgs","repos_url":"https://api.github.com/users/dotnet/repos","events_url":"https://api.github.com/users/dotnet/events{/privacy}","received_events_url":"https://api.github.com/users/dotnet/received_events","type":"Organization","site_admin":false},"html_url":"https://github.com/dotnet/cecil","description":"Cecil is a library to inspect, modify and create .NET programs and libraries.","fork":true,"url":"https://api.github.com/repos/dotnet/cecil","forks_url":"https://api.github.com/repos/dotnet/cecil/forks","keys_url":"https://api.github.com/repos/dotnet/cecil/keys{/key_id}","collaborators_url":"https://api.github.com/repos/dotnet/cecil/collaborators{/collaborator}","teams_url":"https://api.github.com/repos/dotnet/cecil/teams","hooks_url":"https://api.github.com/repos/dotnet/cecil/hooks","issue_events_url":"https://api.github.com/repos/dotnet/cecil/issues/events{/number}","events_url":"https://api.github.com/repos/dotnet/cecil/events","assignees_url":"https://api.github.com/repos/dotnet/cecil/assignees{/user}","branches_url":"https://api.github.com/repos/dotnet/cecil/branches{/branch}","tags_url":"https://api.github.com/repos/dotnet/cecil/tags","blobs_url":"https://api.github.com/repos/dotnet/cecil/git/blobs{/sha}","git_tags_url":"https://api.github.com/repos/dotnet/cecil/git/tags{/sha}","git_refs_url":"https://api.github.com/repos/dotnet/cecil/git/refs{/sha}","trees_url":"https://api.github.com/repos/dotnet/cecil/git/trees{/sha}","statuses_url":"https://api.github.com/repos/dotnet/cecil/statuses/{sha}","languages_url":"https://api.github.com/repos/dotnet/cecil/languages","stargazers_url":"https://api.github.com/repos/dotnet/cecil/stargazers","contributors_url":"https://api.github.com/repos/dotnet/cecil/contributors","subscribers_url":"https://api.github.com/repos/dotnet/cecil/subscribers","subscription_url":"https://api.github.com/repos/dotnet/cecil/subscription","commits_url":"https://api.github.com/repos/dotnet/cecil/commits{/sha}","git_commits_url":"https://api.github.com/repos/dotnet/cecil/git/commits{/sha}","comments_url":"https://api.github.com/repos/dotnet/cecil/comments{/number}","issue_comment_url":"https://api.github.com/repos/dotnet/cecil/issues/comments{/number}","contents_url":"https://api.github.com/repos/dotnet/cecil/contents/{+path}","compare_url":"https://api.github.com/repos/dotnet/cecil/compare/{base}...{head}","merges_url":"https://api.github.com/repos/dotnet/cecil/merges","archive_url":"https://api.github.com/repos/dotnet/cecil/{archive_format}{/ref}","downloads_url":"https://api.github.com/repos/dotnet/cecil/downloads","issues_url":"https://api.github.com/repos/dotnet/cecil/issues{/number}","pulls_url":"https://api.github.com/repos/dotnet/cecil/pulls{/number}","milestones_url":"https://api.github.com/repos/dotnet/cecil/milestones{/number}","notifications_url":"https://api.github.com/repos/dotnet/cecil/notifications{?since,all,participating}","labels_url":"https://api.github.com/repos/dotnet/cecil/labels{/name}","releases_url":"https://api.github.com/repos/dotnet/cecil/releases{/id}","deployments_url":"https://api.github.com/repos/dotnet/cecil/deployments","created_at":"2012-04-26T15:49:43Z","updated_at":"2023-06-24T20:25:22Z","pushed_at":"2023-08-14T12:29:32Z","git_url":"git://github.com/dotnet/cecil.git","ssh_url":"git@github.com:dotnet/cecil.git","clone_url":"https://github.com/dotnet/cecil.git","svn_url":"https://github.com/dotnet/cecil","homepage":"https://cecil.pe","size":19691,"stargazers_count":58,"watchers_count":58,"language":"C#","has_issues":false,"has_projects":false,"has_downloads":true,"has_wiki":false,"has_pages":false,"has_discussions":false,"forks_count":38,"mirror_url":null,"archived":false,"disabled":false,"open_issues_count":1,"license":{"key":"mit","name":"MIT License","spdx_id":"MIT","url":"https://api.github.com/licenses/mit","node_id":"MDc6TGljZW5zZTEz"},"allow_forking":true,"is_template":false,"web_commit_signoff_required":false,"topics":[],"visibility":"public","forks":38,"open_issues":1,"watchers":58,"default_branch":"main","permissions":{"admin":false,"maintain":false,"push":false,"triage":false,"pull":true}}
    ]"

end
