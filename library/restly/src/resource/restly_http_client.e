note
	description: "[
		A RESTLY_PROTOCOL that proxies to a remote HTTP API.
		Inherits RESTLY_HTTP_URI — the client IS its root URL,
		giving it HASHABLE identity and URI_TEMPLATE structure.
	]"

class
	RESTLY_HTTP_CLIENT

inherit
	RESTLY_PROTOCOL [RESTLY_URI_PATH, STRING]

	RESTLY_HTTP_URI
		export
			{NONE} set_template
		redefine
			make_from_uri_template
		end

create
	make_with_url,
	make_from_uri_template

feature {NONE} -- Initialization

	make_with_url (a_base_url: RESTLY_HTTP_URI)
			-- Initialize with base URL `a_base_url`.
		do
			make (a_base_url.template)
			initialize_session
		end

	make_from_uri_template (a_tpl: RESTLY_HTTP_CLIENT)
			-- <Precursor>
		do
			Precursor (a_tpl)
			initialize_session
		end

	initialize_session
			-- Set up HTTP session and context from `template`.
		local
			http_client: LIBCURL_HTTP_CLIENT
		do
			create http_client
			proxy := http_client.new_session (template)
			proxy.set_timeout (10)
			proxy.set_connect_timeout (30)
			create context_proxy.make
			context_proxy.set_credentials_required (False)
			context_proxy.add_header ("User-Agent", "Eiffel RESTLY HTTP Client")
		end

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

feature -- Navigation

	subpath alias "/" (a_segment: STRING): RESTLY_HTTP_CLIENT
			-- Client rooted at Current/`a_segment`.
		require
			error_404_not_found: True
					-- TODO(owner): contract
					-- suggested: reachable endpoint
		do
			create Result.make_with_url (create {RESTLY_HTTP_URI}.make (template.to_string_8 + "/" + a_segment))
		end

feature {NONE} -- Implementation

	proxy: HTTP_CLIENT_SESSION

	context_proxy: HTTP_CLIENT_REQUEST_CONTEXT

end
