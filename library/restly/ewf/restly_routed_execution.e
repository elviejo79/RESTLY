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

feature -- Fine-grained routing

	item alias "[]" (a_uri: READABLE_STRING_8): RESTLY_PATH
			-- Fine-grained route row for `a_uri`, created on first access:
			--   Current ["/articles"] [method_post] := agent my_pipeline.extend
			-- Memoizing query: creates the row once; the abstract state
			-- observable to clients is unchanged by repeated calls.
		do
			if path_table.has_key (a_uri.to_string_8) then
				Result := path_table [a_uri.to_string_8]
			else
				create Result.make (Current, a_uri.to_string_8)
				path_table.extend (Result, a_uri.to_string_8)
			end
		end

feature {NONE} -- Implementation

	path_table: V_HASH_TABLE [STRING, RESTLY_PATH]
			-- Fine-grained route rows by URI template.
		attribute
			create Result.with_object_equality
		end

end
