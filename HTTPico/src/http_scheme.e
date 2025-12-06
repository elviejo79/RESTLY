note
	description: "Generic HTTP client for RESTful APIs with JSON"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTP_SCHEME [R -> {JSON_OBJECT} create make_from_string, make_empty end]

inherit
	PICO_SCHEME_HANDLER [R]
		redefine
			can_connect
		end

feature {NONE} -- Initialization

	make (a_root: URI)
			-- Initialize with URL
		do
			base_uri := a_root
		end

feature -- Attributes

	Valid_scheme: ARRAY[STRING_8]
			-- This client handles http:// and https:// URLs
		once
			Result := << "http", "https" >>
			Result.compare_objects
		end

	Max_redirects: INTEGER = 10
			-- Maximum number of redirects to follow

feature -- Status

	can_connect (a_uri: URI): BOOLEAN
			-- Check if server at `a_uri` is reachable
		local
			http_client: DEFAULT_HTTP_CLIENT
			session: HTTP_CLIENT_SESSION
			context: HTTP_CLIENT_REQUEST_CONTEXT
			response: HTTP_CLIENT_RESPONSE
		do
			create http_client
			session := http_client.new_session (a_uri.string)
			session.set_timeout (5)
			session.set_connect_timeout (5)
			create context.make
			response := session.get ("", context)
			Result := response.status > 0
		rescue
			Result := False
		end

feature -- http_client attributes
	proxy: 	HTTP_CLIENT_SESSION
		local
			http_client: DEFAULT_HTTP_CLIENT
			context: HTTP_CLIENT_REQUEST_CONTEXT

		once
				-- Create HTTP client
			create http_client
			Result := http_client.new_session (base_uri.string)
			Result.set_timeout (10)
			Result.set_connect_timeout (30)
			Result.set_debug_verbose(True)
		end

	context_proxy: HTTP_CLIENT_REQUEST_CONTEXT
		once
			create Result.make
			Result.set_credentials_required (False)
			Result.add_header ("User-Agent", "Eiffel Repository Reporter")
		end

	context_with_json: HTTP_CLIENT_REQUEST_CONTEXT
		once
			Result := context_proxy.twin
			Result.add_header ("Content-Type", "application/json")
		end

feature -- http helper

	-- ensure_trailing_slash (a_url: STRING_8): STRING_8
	-- 		-- Ensure `a_url` ends with a trailing slash
	-- 	do
	-- 		if a_url.ends_with ("/") then
	-- 			Result := a_url
	-- 		else
	-- 			Result := a_url + "/"
	-- 		end
	-- 	end

	build_absolute_url (a_path: PATH_PICO): STRING_8
			-- Build absolute URL from base_uri and path, ensuring trailing slash
		do
			Result := base_uri.string + a_path.out
		end

	get_location_header (a_response: HTTP_CLIENT_RESPONSE): detachable STRING
			-- Get Location header from response (case-insensitive)
		do
			if attached a_response.header ("location") as loc then
				Result := loc
			elseif attached a_response.header ("Location") as loc then
				Result := loc
			end
		end

	extract_id_from_response (a_response: HTTP_CLIENT_RESPONSE): detachable PATH_PICO
			-- Extract ID from response Location header or body
			-- API-specific: implement in descendant classes
		deferred
		end

get_following_redirects (a_path: PATH_PICO; a_max_redirects: INTEGER): HTTP_CLIENT_RESPONSE
    local
        l_url: STRING_8
        l_response: detachable HTTP_CLIENT_RESPONSE
        redirects_remaining: INTEGER
    do
        from
            l_url := a_path.out
            redirects_remaining := a_max_redirects
        variant
            redirects_remaining
        until
            redirects_remaining = 0
        loop
            l_response := proxy.get (l_url, context_proxy)

            if l_response.status = 200 then
                redirects_remaining := 0
            elseif l_response.status >= 300 and l_response.status < 400 then
                if attached get_location_header (l_response) as l_location then
                    l_url := l_location
                    redirects_remaining := redirects_remaining - 1
                else
                    redirects_remaining := 0
                end
            else
                redirects_remaining := 0
            end
        end
        check attached l_response as r then
            Result := r
        end
    end


feature --http verbs
has_key (a_path: PATH_PICO): BOOLEAN
    local
        response: HTTP_CLIENT_RESPONSE
    do
        response := get_following_redirects (a_path, Max_redirects)
        Result := response.status = 200
    end

item alias "[]" (a_path: PATH_PICO): R
    local
        response: HTTP_CLIENT_RESPONSE
        l_exception: POSTCONDITION_VIOLATION
    do
        create Result.make_empty
        response := get_following_redirects (a_path, Max_redirects)
        if response.status = 200 and then attached response.body as body then
            create Result.make_from_string (body)
        else
            create l_exception
        end
    end

	force (data: R; a_path: PATH_PICO)
			-- Update item at `a_path` with `data` using HTTP PUT
		local
			response: HTTP_CLIENT_RESPONSE
			l_exception: POSTCONDITION_VIOLATION
			l_url: STRING_8
			retrieved: R
		do
			l_url := build_absolute_url (a_path)
			io.put_string ("%N=== DEBUG force ===%N")
			io.put_string ("Sending data: " + data.representation + "%N")
			response := proxy.put (l_url, context_with_json, data.representation)

			-- Follow redirect if needed
			if response.status >= 300 and response.status < 400 then
				if attached get_location_header (response) as loc then
					response := proxy.put (loc, context_with_json, data.representation)
				end
			end

			if response.status /= 200 then
				create l_exception
			end

			io.put_string ("Response status: " + response.status.out + "%N")
			if attached response.body as body then
				io.put_string ("Response body: " + body + "%N")
			end

			retrieved := item (a_path)
			io.put_string ("Retrieved after PUT: " + retrieved.representation + "%N")
			io.put_string ("Are they equal? " + (data ~ retrieved).out + "%N")
			io.put_string ("=== END DEBUG ===%N%N")

			last_inserted_key := a_path
		end

	remove (a_path: PATH_PICO)
		local
			response: HTTP_CLIENT_RESPONSE
			l_exception: POSTCONDITION_VIOLATION
			l_url: STRING_8
		do
			l_url := build_absolute_url (a_path)
			response := proxy.delete (l_url, context_proxy)
			if not (response.status = 200 or response.status = 204) then
				create l_exception
			end
		end

	collection_extend (data: R)
			-- Equivalent to http POST
			-- API-specific: implement in descendant classes
		deferred
		end

	last_inserted_key: detachable PATH_PICO
		attribute
			Result := Void
		end

end
