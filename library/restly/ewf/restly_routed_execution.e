note
	description: "[
		Reusable WSF execution for RESTLY resources.
		Descendants implement setup_router only:
		Current ["/todos/{id}"] [method_get] := agent my_handler.item
	]"

deferred class
	RESTLY_ROUTED_EXECUTION

inherit
	WSF_ROUTED_EXECUTION

	WSF_ROUTED_URI_TEMPLATE_HELPER

	RESTLY_CONTRACT_TO_HTTP
			-- CORS headers for the command-verb path; the query-verb
			-- path gets them from EWF_CONTRACT_GUARD.

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

	map_command_verb (a_methods: WSF_REQUEST_METHODS; a_resource_path: RESTLY_URI_PATH; an_action: PROCEDURE [WSF_JSON_RESPONSE, WSF_REQUEST])
			-- Route `a_methods' requests on `a_resource_path' to `an_action',
			-- creating the response message the command mutates.
		do
			map_uri_template_agent (a_resource_path, agent execute_command (an_action, ?, ?), a_methods)
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

	execute_command (an_action: PROCEDURE [WSF_JSON_RESPONSE, WSF_REQUEST]; req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Create the response message, run `an_action` on it, send it.
		local
			l_json: WSF_JSON_RESPONSE
		do
			create l_json.make
			an_action (l_json, req)
			add_cors_headers (l_json)
			res.send (l_json)
		end

	path_table: V_HASH_TABLE [STRING, RESTLY_PATH]
			-- Fine-grained route rows by URI template.
		attribute
			create Result.with_object_equality
		end

end
