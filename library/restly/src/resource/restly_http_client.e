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
		local
			http_client: LIBCURL_HTTP_CLIENT
		do
			base_url := a_base_url
			create http_client
			proxy := http_client.new_session (a_base_url)
			proxy.set_timeout (10)
			proxy.set_connect_timeout (30)
			create context_proxy.make
			context_proxy.set_credentials_required (False)
			context_proxy.add_header ("User-Agent", "Eiffel RESTLY HTTP Client")
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

	context_proxy: HTTP_CLIENT_REQUEST_CONTEXT
			-- Default request context (no credentials, RESTLY user agent).

end
