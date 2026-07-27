note
	description: "[
		One URI template's row of an execution's fine-grained route
		table: verb -> action. Assigning a cell maps it on the
		execution's router at once:
			Current ["/articles"] [method_post] := agent my_pipeline.extend
	]"

class
	RESTLY_PATH

inherit
	HTTP_REQUEST_METHODS
		export
			{NONE} all
		end

create
	make

feature {NONE} -- Initialization

	make (an_execution: RESTLY_ROUTED_EXECUTION; a_uri: RESTLY_URI_PATH)
			-- Row of `an_execution's route table for `a_uri`.
		do
			execution := an_execution
			uri := a_uri
			create table.with_object_equality
		end

feature -- Access

	item alias "[]" (a_method: READABLE_STRING_8): ROUTINE [TUPLE] assign put
			-- Action registered for `a_method`.
			-- TODO(owner): contract
		do
			Result := table [a_method.to_string_8]
		end

feature -- Element change

	put (an_action: ROUTINE [TUPLE]; a_method: READABLE_STRING_8)
			-- Register `an_action` for `a_method` on this row's URI
			-- and map it on the execution's router by CQS shape:
			-- queries return the response message, commands mutate it.
		require
			query_binds_function: is_query_method (a_method) ⇒ attached {FUNCTION [WSF_REQUEST, WSF_RESPONSE_MESSAGE]} an_action
		do
			if attached {FUNCTION [WSF_REQUEST, WSF_RESPONSE_MESSAGE]} an_action as l_query then
				execution.map_verb (methods_from (a_method), uri, l_query)
			elseif attached {PROCEDURE [WSF_JSON_RESPONSE, WSF_REQUEST]} an_action as l_command then
				execution.map_command_verb (methods_from (a_method), uri, l_command)
			else
				check known_agent_shape: False end
			end
			table.extend (an_action, a_method.to_string_8)
		end

feature -- Status report

	is_query_method (a_method: READABLE_STRING_8): BOOLEAN
			-- Is `a_method` a query verb, whose action must be a
			-- FUNCTION returning the response message?
			-- Public: used in exported preconditions (VAPE).
		do
			Result := a_method ~ method_get ∨ a_method ~ method_head ∨ a_method ~ "SEARCH"
		end

feature {NONE} -- Implementation

	execution: RESTLY_ROUTED_EXECUTION
			-- Execution whose router receives the mappings.

	uri: RESTLY_URI_PATH
			-- URI template of this row.

	table: V_HASH_TABLE [STRING, ROUTINE [TUPLE]]
			-- Registered actions by method name.

	methods_from (a_method: READABLE_STRING_8): WSF_REQUEST_METHODS
			-- Singleton method set for `a_method`.
		do
			create Result
			if a_method ~ method_get then
				Result.enable_get
			elseif a_method ~ method_post then
				Result.enable_post
			elseif a_method ~ method_put then
				Result.enable_put
			elseif a_method ~ method_delete then
				Result.enable_delete
			elseif a_method ~ method_patch then
				Result.enable_patch
			elseif a_method ~ method_options then
				Result.enable_options
			elseif a_method ~ method_head then
				Result.enable_head
			else
				Result.enable_custom (a_method)
			end
		end

end
