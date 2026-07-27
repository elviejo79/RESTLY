note
	description: "Declares the routes of the todobackend, backed by SQLite."

class
	TODOBACKEND_EXECUTION

inherit
	RESTLY_ROUTED_EXECUTION

	HTTP_REQUEST_METHODS
		export
			{NONE} all
		end

create
	make

feature {NONE} -- Router

	setup_router
		local
			gw: GATEWAY
			l_handler: RESTLY_EWF_HANDLER
		do
			gw := (create {GATEWAY}) <| (create {TODO_CODEC}) <| todos_table
			Current ["/todos"] [method_get] := agent gw.items
			Current ["/todos"] [method_head] := agent gw.items
			Current ["/todos"] [method_post] := agent gw.extend
			Current ["/todos"] [method_delete] := agent gw.wipe_out
			Current ["/todos"] [method_options] := agent gw.preflight_ok
			Current ["/todos/{id}"] [method_get] := agent gw.item
			Current ["/todos/{id}"] [method_head] := agent gw.head
			Current ["/todos/{id}"] [method_patch] := agent gw.merge
			Current ["/todos/{id}"] [method_delete] := agent gw.remove
			Current ["/todos/{id}"] [method_options] := agent gw.preflight_ok

			l_handler := (create {RESTLY_EWF_HANDLER}) <| (create {TODO_CODEC}) <| todos_table
			Current ["/restly/todos/{id}"] [method_get] := agent l_handler.item
			Current ["/restly/todos/{id}"] [method_post] := agent l_handler.extend
			Current ["/restly/todos/{id}"] [method_put] := agent l_handler.put
			Current ["/restly/todos/{id}"] [method_delete] := agent l_handler.remove
		end

feature -- Access

	todos_table: RESTLY_TABLE_RESOURCE [TODO_ROW]
			-- Shared across all request executions.
			-- once ("PROCESS"): plain `once' is once-per-thread, so each
			-- connection thread would get its own store.
			-- ponytail: file db with pre-built schema (ABEL does not create
			-- tables); ":memory:" once schema bootstrap exists.
		once ("PROCESS")
			create Result.make ({SCHEME}.sqlite ("todobackend.db") / {TODO_ROW})
		end

end
