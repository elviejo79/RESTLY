note
	description: "Summary description for {GITHUB_PROXY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	API_RESOURCE

inherit
	HTTPICO_VERBS [STRING]
		undefine
			is_equal, copy
		end
	HTTPICO_RESOURCE

create
	make_with_url

feature -- http_client attributes
	proxy: HTTP_CLIENT_SESSION
		local
			http_client: DEFAULT_HTTP_CLIENT
			context: HTTP_CLIENT_REQUEST_CONTEXT

		once
				-- Create HTTP client
			create http_client
			Result := http_client.new_session (address.string)
			Result.set_timeout (10)
			Result.set_connect_timeout (30)
		end

	context_proxy: HTTP_CLIENT_REQUEST_CONTEXT
		once
			create Result.make
			Result.set_credentials_required (False)

				-- Add headers to context
				--Result.add_header ("Accept", "application/vnd.github.v3+json")
			Result.add_header ("User-Agent", "Eiffel Repository Reporter")
		end
feature --http verbs
	has_key (a_path: PATH_HTTPICO): BOOLEAN
		local
			response: HTTP_CLIENT_RESPONSE
		do
			response := proxy.head (a_path.out, context_proxy)
			Result := 200 ~ response.status
		end

	item alias "[]" (a_path: PATH_HTTPICO): STRING
		local
			response: HTTP_CLIENT_RESPONSE
			l_exception: POSTCONDITION_VIOLATION
		do
			create Result.make_empty
			response := proxy.get (a_path.out, context_proxy)
			if response.status = 200 and then attached response.body as body then
				Result := body
			else
				create l_exception
			end
		end

	force (data: STRING; a_path: PATH_HTTPICO)
		local
			response: HTTP_CLIENT_RESPONSE
			l_exception: POSTCONDITION_VIOLATION
		do
			response := proxy.post (a_path.out, context_proxy, data)
			check response.status ~ 200 and then attached response.body as body then
--				Result := body
			end
		end

	remove (a_path: PATH_HTTPICO)
		do
				-- should throw an exception
		end

	collection_extend (data: STRING)
		do
				-- should throw an exception
		end

	last_inserted_key: PATH_HTTPICO
		attribute
			create Result.make_from_string ("")
		end

end
