note
	description: "[
		Tests for RESTLY_HTTP_CLIENT against a local todobackend server
		(examples/todobackend, port 8080) — a RESTLY client proxying a
		RESTLY server. The server must be running for these to pass.

		Verbs exercised: has_key (HEAD), item (GET), remove (DELETE).
		Not exercised: force/put (server routes no PUT) and extend
		(server only accepts POST on the collection, whose key always
		exists, so extend's fresh-key precondition cannot be met).

		Seeding bypasses the protocol (raw POST) because creation is
		the server's job — the client under test only reads and deletes.
	]"

class
	TEST_RESTLY_HTTP_CLIENT

inherit
	EQA_TEST_SET

feature {NONE} -- Fixtures

	server_url: STRING = "http://localhost:8080"

	api: RESTLY_HTTP_CLIENT
		attribute Result := {RESTLY_SCHEME}.http (server_url) end

	seeded_path: STRING
			-- Element path of a todo created via raw POST.
		attribute
			Result := post_seed ("{%"title%": %"seeded by test%"}")
		end

	post_seed (a_json: STRING): STRING
			-- POST `a_json' to /todos; element path from the Location header.
		local
			client: LIBCURL_HTTP_CLIENT
			session: HTTP_CLIENT_SESSION
			response: HTTP_CLIENT_RESPONSE
		do
			create client
			session := client.new_session (server_url)
			response := session.post ("/todos", Void, a_json)
			check location_header_present: attached response.header ("Location") as l_location then
				Result := l_location.substring (l_location.substring_index ("/todos/", 1), l_location.count).to_string_8
			end
		end

feature -- HEAD (has_key)

	test_has_key_true_for_seeded_element
		do
			assert ("seeded element exists", api.has_key (seeded_path))
		end

	test_has_key_false_for_missing_element
		do
			assert ("missing element is absent", not api.has_key ("/todos/999999"))
		end

	test_has_key_true_for_collection
		do
			assert ("collection exists", api.has_key ("/todos"))
		end

feature -- GET (item)

	test_item_returns_seeded_body
		local
			body: STRING
		do
			body := api [seeded_path]
			assert ("body not empty", not body.is_empty)
			assert ("body carries seeded title", body.has_substring ("seeded by test"))
		end

	test_item_on_collection_lists_seeded_element
		local
			body: STRING
		do
			body := api [seeded_path]	-- force the seed
			body := api ["/todos"]
			assert ("collection lists seeded element", body.has_substring ("seeded by test"))
		end

feature -- Transport failure

	test_transport_failure_raises
			-- A dead endpoint must raise, not silently answer False.
		local
			l_dead: RESTLY_HTTP_CLIENT
			l_raised: BOOLEAN
			l_ignored: BOOLEAN
		do
			if not l_raised then
				create l_dead.make_with_url ("http://localhost:59999")
				l_ignored := l_dead.has_key ("/todos")
			end
			assert ("transport failure raised", l_raised)
		rescue
			l_raised := True
			retry
		end

feature -- DELETE (remove)

	test_remove_deletes_element
		do
			api.remove (seeded_path)
			assert ("element gone after remove", not api.has_key (seeded_path))
		end

end
