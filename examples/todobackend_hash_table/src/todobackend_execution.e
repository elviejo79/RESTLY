note
	description: "Wires the RESTLY pipeline to the EWF router."

class
	TODOBACKEND_EXECUTION

inherit
	GATEWAY

create
	make

feature {NONE} -- Router

	setup_router
		do
			mount_resource ("/todos", todo_resource)
			print_pipeline_graph
		end

feature {NONE} -- Diagnostics

	print_pipeline_graph
			-- Dump the composition as GraphViz dot (first request only).
			-- Render with: dot -Tpdf
		once ("PROCESS")
			io.put_string (todo_resource.graph_description)
		end

feature -- Access

	todo_resource: TODO_STORE
			-- Shared across all request executions.
			-- once ("PROCESS"): plain `once' is once-per-thread, so each
			-- connection thread would get its own empty store.
		once ("PROCESS")
			create Result.make("todos")
		end

end

