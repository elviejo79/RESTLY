note
	description: "Summary description for {GITHUB_PROXY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_SCHEME[R]

inherit
	SCHEME_CLIENT[R]

create
	make

feature {NONE} -- Initialization

	make (a_root: URI)
			-- Initialize with URL
		do
			base_uri := a_root
		end

feature -- Attributes

	Valid_scheme: STRING_8 = "http"
			-- This client handles http:// URLs

feature -- http_client attributes
	proxy: HTTP_CLIENT_SESSION
		local
			http_client: DEFAULT_HTTP_CLIENT
			context: HTTP_CLIENT_REQUEST_CONTEXT

		once
				-- Create HTTP client
			create http_client
			Result := http_client.new_session (base_uri.string)
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
	has_key (a_path: PATH_OR_STRING): BOOLEAN
		local
			response: HTTP_CLIENT_RESPONSE
		do
			response := proxy.head (a_path.out, context_proxy)
			Result := 200 ~ response.status
		end

	item alias "[]" (a_path: PATH_OR_STRING): R
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

	force (data: R; a_path: PATH_OR_STRING)
		local
			response: HTTP_CLIENT_RESPONSE
			l_exception: POSTCONDITION_VIOLATION
		do
			response := proxy.post (a_path.out, context_proxy, data.out)
			check response.status ~ 200 and then attached response.body as body then
--				Result := body
			end
		end

      remove (a_path: PATH_OR_STRING)
   		local
			response: HTTP_CLIENT_RESPONSE
			l_exception: POSTCONDITION_VIOLATION
		do
			response := proxy.delete (a_path.out, context_proxy)
			if not (response.status ~ 200) then
            create l_exception
			end
		end

	collection_extend (data: R)
		local
      response: HTTP_CLIENT_RESPONSE
         l_precondition: PRECONDITION_VIOLATION
			l_postcondition: POSTCONDITION_VIOLATION
		do
			response := proxy.post ("", context_proxy, data.out)
			if response.status < 400 then
            -- it returned something ok, could be a 200 ok or a 301
         -- redirect
   elseif response.status < 500 then
      create l_precondition
   else
      create l_postcondition

			end
		end

	last_inserted_key: PATH_OR_STRING
		attribute
			create Result.make_from_string ("")
		end

end
