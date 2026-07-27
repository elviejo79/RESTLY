note
	description: "[
		Declares the routes of the todobackend, backed by SQLite
		through ABEL's generic object-graph layout: schema is
		bootstrapped by ABEL, so the database lives in memory.
	]"

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
			l_handler: RESTLY_EWF_HANDLER
			l_codec: TODO_CODEC
		do
			create l_codec
			l_codec.base_url := "http://localhost:8080/todos/"
			l_handler := (create {RESTLY_EWF_HANDLER}) <| l_codec <| todos_table
			Current ["/todos/{id}"] [method_get] := agent l_handler.item
			Current ["/todos/{id}"] [method_put] := agent l_handler.put
			Current ["/todos/{id}"] [method_delete] := agent l_handler.remove
			Current ["/todos"] [method_get] := agent l_handler.items
			Current ["/todos"] [method_post] := agent l_handler.extend_new
			Current ["/todos"] [method_delete] := agent l_handler.wipe_out
			Current ["/todos/{id}"] [method_patch] := agent l_handler.merge
			Current ["/todos"] [method_options] := agent l_handler.preflight_ok
			Current ["/todos/{id}"] [method_options] := agent l_handler.preflight_ok
				-- TODO(handler): collection HEAD needs a body-less `items`; element HEAD needs `head`
		end

feature -- Access

	todos_table: RESTLY_TABLE_RESOURCE [TODO_ROW]
			-- Shared across all request executions.
			-- once ("PROCESS"): plain `once' is once-per-thread, so each
			-- connection thread would get its own store; the in-memory
			-- SQLite database lives exactly as long as the process.
		once ("PROCESS")
			create Result.make ({SCHEME}.sqlite_graph (":memory:") / {TODO_ROW})
		end

end
