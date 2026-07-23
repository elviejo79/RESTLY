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

	item alias "[]" (a_method: READABLE_STRING_8): FUNCTION [WSF_REQUEST, WSF_RESPONSE_MESSAGE] assign put
			-- Action registered for `a_method`.
			-- TODO(owner): contract
		do
			Result := table [a_method.to_string_8]
		end

feature -- Element change

	put (an_action: FUNCTION [WSF_REQUEST, WSF_RESPONSE_MESSAGE]; a_method: READABLE_STRING_8)
			-- Register `an_action` for `a_method` on this row's URI
			-- and map it on the execution's router.
		do
			execution.map_verb (methods_from (a_method), uri, an_action)
			table.extend (an_action, a_method.to_string_8)
		end

feature {NONE} -- Implementation

	execution: RESTLY_ROUTED_EXECUTION
			-- Execution whose router receives the mappings.

	uri: RESTLY_URI_PATH
			-- URI template of this row.

	table: V_HASH_TABLE [STRING, FUNCTION [WSF_REQUEST, WSF_RESPONSE_MESSAGE]]
			-- Registered actions by method name.

	methods_from (a_method: READABLE_STRING_8): WSF_REQUEST_METHODS
			-- Singleton method set for `a_method`.
		do
			create Result
			if a_method.same_string (method_get) then
				Result.enable_get
			elseif a_method.same_string (method_post) then
				Result.enable_post
			elseif a_method.same_string (method_put) then
				Result.enable_put
			elseif a_method.same_string (method_delete) then
				Result.enable_delete
			elseif a_method.same_string (method_patch) then
				Result.enable_patch
			elseif a_method.same_string (method_options) then
				Result.enable_options
			elseif a_method.same_string (method_head) then
				Result.enable_head
			else
				Result.enable_custom (a_method)
			end
		end

end
