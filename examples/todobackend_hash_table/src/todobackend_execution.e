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
			l_handler := (create {RESTLY_EWF_HANDLER}) <| todo_store
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
			print_pipeline_graph
		end

feature {NONE} -- Diagnostics

	print_pipeline_graph
			-- Dump the composition as GraphViz dot (first request only).
			-- Render with: dot -Tpdf
		once ("PROCESS")
			io.put_string (todo_store.graph_description)
		end

feature -- Access

	todo_store: TODO_STORE
			-- Shared across all request executions.
			-- once ("PROCESS"): plain `once' is once-per-thread, so each
			-- connection thread would get its own empty store.
		once ("PROCESS")
			create Result.make ("todos")
		end

end
