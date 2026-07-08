note
	description: "A RESTLY_PROTOCOL that proxies to a remote HTTP API."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	RESTLY_HTTP_CLIENT

inherit
	RESTLY_PROTOCOL [RESTLY_URI_PATH, STRING]

	ANY

create
	make_with_url

feature {NONE} -- Initialization

	make_with_url (a_base_url: STRING)
			-- Initialize with base URL `a_base_url`.
		do
			base_url := a_base_url
		end

feature -- Access

	base_url: STRING
			-- Base URL for the remote API.

feature -- REST verbs

	has_key (k: RESTLY_URI_PATH): BOOLEAN
		local
			response: HTTP_CLIENT_RESPONSE
		do
			response := proxy.head (k, context_proxy)
			Result := 200 ~ response.status
		end

	item alias "[]" (k: RESTLY_URI_PATH): STRING assign force
		local
			response: HTTP_CLIENT_RESPONSE
		do
			create Result.make_empty
			response := proxy.get (k, context_proxy)
			if response.status = 200 and then attached response.body as body then
				create Result.make_from_string (body)
			end
		end

	force (v: STRING; k: RESTLY_URI_PATH)
		local
			response: HTTP_CLIENT_RESPONSE
		do
			response := proxy.put (k, context_proxy, v)
		end

	put (v: STRING; k: RESTLY_URI_PATH)
		local
			response: HTTP_CLIENT_RESPONSE
		do
			response := proxy.put (k, context_proxy, v)
		end

	extend (v: STRING; k: RESTLY_URI_PATH)
		local
			response: HTTP_CLIENT_RESPONSE
		do
			response := proxy.post (k, context_proxy, v)
		end

	remove (k: RESTLY_URI_PATH)
		local
			response: HTTP_CLIENT_RESPONSE
		do
			response := proxy.delete (k, context_proxy)
		end

feature {NONE} -- Implementation

	proxy: HTTP_CLIENT_SESSION
			-- Session against `base_url`.
			-- Needs thread concurrency: libcurl no-ops under support="none".
		local
			http_client: LIBCURL_HTTP_CLIENT
		once
			create http_client
			Result := http_client.new_session (base_url)
			Result.set_timeout (10)
			Result.set_connect_timeout (30)
		end

	context_proxy: HTTP_CLIENT_REQUEST_CONTEXT
		once
			create Result.make
			Result.set_credentials_required (False)
			Result.add_header ("User-Agent", "Eiffel RESTLY HTTP Client")
		end

end
