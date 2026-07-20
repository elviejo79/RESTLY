note
	description: "[
		Reusable WSF execution for RESTLY resources.
		Descendants implement setup_router only:
		routes ["/todos"] := (create {MY_GATEWAY}) <| my_store
	]"

deferred class
	RESTLY_ROUTED_EXECUTION

inherit
	WSF_ROUTED_EXECUTION

	WSF_ROUTED_URI_TEMPLATE_HELPER

feature -- Routing

	routes: RESTLY_ROUTES
			-- Route table of this execution.
		attribute
			create Result.make (Current)
		end

	map_verb (a_methods: WSF_REQUEST_METHODS; a_resource_path: RESTLY_URI_PATH; an_action: FUNCTION [WSF_REQUEST, WSF_RESPONSE_MESSAGE])
			-- Route `a_methods' requests on `a_resource_path' to `an_action'.
		do
			map_uri_template_response (a_resource_path, create {EWF_CONTRACT_GUARD}.make (an_action), a_methods)
		end

end
