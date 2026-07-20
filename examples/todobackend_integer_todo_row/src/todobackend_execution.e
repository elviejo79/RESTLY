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
			routes ["/todos"] := (create {GATEWAY}) <| (create {TODO_CONVERTER}) <| todos_table
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
