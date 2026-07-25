note
	description: "Declares the routes of the todobackend."

class
	TODOBACKEND_EXECUTION

inherit
	RESTLY_ROUTED_EXECUTION

create
	make

feature {NONE} -- Router

	setup_router
		do
			routes ["/todos"] := (create {GATEWAY}) <| todo_store
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
