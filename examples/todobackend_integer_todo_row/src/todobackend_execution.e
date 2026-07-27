note
	description: "Declares the routes of the todobackend."

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
		do
			l_handler := (create {RESTLY_EWF_HANDLER}) <| (create {TODO_CODEC}) <| todos_table
			Current ["/todos/{id}"] [method_get] := agent l_handler.item
			Current ["/todos/{id}"] [method_put] := agent l_handler.put
			Current ["/todos/{id}"] [method_delete] := agent l_handler.remove
				-- TODO(handler): collection GET/HEAD need `items` (LISTABLE traversal + representation)
				-- TODO(handler): collection POST needs `extend_new` (POSTABLE, PRG 303)
				-- TODO(handler): collection DELETE needs `wipe_out` (LISTABLE)
				-- TODO(handler): OPTIONS needs `preflight_ok`; element HEAD needs `head`; PATCH needs `merge`
			print_pipeline_graph
		end

feature {NONE} -- Diagnostics

	print_pipeline_graph
			-- Dump the composition as GraphViz dot (first request only).
			-- Render with: dot -Tpdf
		once ("PROCESS")
			io.put_string (todos_table.graph_description)
		end

feature -- Access

	todos_table: TABLE_INTEGER_TODO_ROW
			-- Shared across all request executions.
			-- once ("PROCESS"): plain `once' is once-per-thread, so each
			-- connection thread would get its own empty store.
		once ("PROCESS")
			create Result.make ("todos")
		end

end
