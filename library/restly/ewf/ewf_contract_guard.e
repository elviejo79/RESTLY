note
	description: "[
		Guards one route: maps contract blame to HTTP statuses.
		Adapts a single verb action agent to a WSF URI-template handler,
		wrapping the call with rescue/retry and CORS headers.
		The mapping machinery lives in RESTLY_CONTRACT_TO_HTTP.
	]"

class
	EWF_CONTRACT_GUARD

inherit
	WSF_URI_TEMPLATE_RESPONSE_HANDLER

	RESTLY_CONTRACT_TO_HTTP

create
	make

feature {NONE} -- Initialization

	make (an_action: FUNCTION [WSF_REQUEST, WSF_RESPONSE_MESSAGE])
			-- Initialize with `an_action'.
		do
			action := an_action
		end

feature -- Access

	action: FUNCTION [WSF_REQUEST, WSF_RESPONSE_MESSAGE]
			-- Verb action producing the response.

feature -- Dispatch

	response (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- Run `action' with rescue/retry error mapping.
		do
			if attached Result then
					-- retry path: Result was set by handle_rescue
			else
				Result := action (req)
			end
			add_cors_headers (Result)
		rescue
			Result := handle_rescue_for_queries
			retry
		end

end
