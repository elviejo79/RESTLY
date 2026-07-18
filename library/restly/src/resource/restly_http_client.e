note
	description: "[
		A RESTLY_PROTOCOL that proxies to a remote HTTP API.
		Inherits RESTLY_HTTP_URI — the client IS its root URL,
		giving it HASHABLE identity and URI_TEMPLATE structure.

		Response status handling:
		  2xx — success
		  3xx — followed automatically (libcurl, max 5 redirects)
		  4xx — PRECONDITION_VIOLATION  (client sent a bad request)
		  5xx — retry up to 3 attempts, then POSTCONDITION_VIOLATION
		  0   — transport failure (no HTTP conversation happened);
		        retry up to 3 attempts, then DEVELOPER_EXCEPTION
		        carrying libcurl's error message
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

	RESTLY_ADDRESSABLE

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
			l_retries: INTEGER
			l_status: INTEGER
		do
			response := proxy.head (k, context_proxy)
			l_status := response.status
			if l_status = 0 then
				raise_transport_error (response)
			elseif l_status >= 200 and l_status < 300 then
				Result := True
			elseif l_status >= 500 then
				raise_server_error (l_status)
			elseif l_status >= 400 and l_status /= 404 then
				raise_client_error (l_status)
			end
		rescue
			l_retries := l_retries + 1
			if (l_status >= 500 or l_status = 0) and l_retries < Max_server_retries then
				(create {EXECUTION_ENVIRONMENT}).sleep (Retry_wait_nanoseconds)
				retry
			end
		end

	item alias "[]" (k: RESTLY_URI_PATH): STRING assign force
		local
			response: HTTP_CLIENT_RESPONSE
		do
			response := checked (agent proxy.get (k, context_proxy))
			if attached response.body as body then
				create Result.make_from_string (body)
			else
				create Result.make_empty
			end
		end

	put (v: STRING; k: RESTLY_URI_PATH)
		local
			l_response: HTTP_CLIENT_RESPONSE
		do
			l_response := checked (agent proxy.put (k, context_proxy, v))
		end

	extend (v: STRING; k: RESTLY_URI_PATH)
		local
			l_response: HTTP_CLIENT_RESPONSE
		do
			l_response := checked (agent proxy.post (k, context_proxy, v))
		end

	remove (k: RESTLY_URI_PATH)
		local
			l_response: HTTP_CLIENT_RESPONSE
		do
			l_response := checked (agent proxy.delete (k, context_proxy))
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

feature {NONE} -- Response handling

	checked (a_call: FUNCTION [TUPLE, HTTP_CLIENT_RESPONSE]): HTTP_CLIENT_RESPONSE
			-- Execute `a_call`; retry on 5xx and transport failure,
			-- raise on 4xx.
		local
			l_retries: INTEGER
			l_status: INTEGER
		do
			Result := a_call ([])
			l_status := Result.status
			if l_status = 0 then
				raise_transport_error (Result)
			elseif l_status >= 500 then
				raise_server_error (l_status)
			elseif l_status >= 400 then
				raise_client_error (l_status)
			end
		rescue
			l_retries := l_retries + 1
			if (l_status >= 500 or l_status = 0) and l_retries < Max_server_retries then
				(create {EXECUTION_ENVIRONMENT}).sleep (Retry_wait_nanoseconds)
				retry
			end
		end

	raise_client_error (a_status: INTEGER)
			-- Raise precondition violation for 4xx client error.
		local
			l_exc: PRECONDITION_VIOLATION
		do
			create l_exc
			l_exc.set_description ("HTTP " + a_status.out)
			l_exc.raise
		end

	raise_server_error (a_status: INTEGER)
			-- Raise postcondition violation for 5xx server error.
		local
			l_exc: POSTCONDITION_VIOLATION
		do
			create l_exc
			l_exc.set_description ("HTTP " + a_status.out)
			l_exc.raise
		end

	raise_transport_error (a_response: HTTP_CLIENT_RESPONSE)
			-- Raise developer exception for transport failure:
			-- status 0 means libcurl never got an HTTP status line
			-- (connection refused, DNS failure, timeout, ...).
		local
			l_exc: DEVELOPER_EXCEPTION
		do
			create l_exc
			if attached a_response.error_message as l_message then
				l_exc.set_description ("HTTP transport failure: " + l_message)
			else
				l_exc.set_description ("HTTP transport failure: no status from " + template.to_string_8)
			end
			l_exc.raise
		end

feature {NONE} -- Constants

	Max_server_retries: INTEGER = 3

	Retry_wait_nanoseconds: INTEGER_64 = 2_000_000_000
			-- 2 seconds between retry attempts.

feature {NONE} -- Implementation

	proxy: HTTP_CLIENT_SESSION

	context_proxy: HTTP_CLIENT_REQUEST_CONTEXT

end
