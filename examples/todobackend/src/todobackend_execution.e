note
	description: "Wires the RESTLY pipeline to the EWF router."

class
	TODOBACKEND_EXECUTION

inherit
	RESTLY_EWF_SERVER

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
		once
			io.put_string (todo_resource.graph_description)
		end

feature -- Access

	todo_resource: RESTLY_JSON_RESOURCE
			-- Shared across all request executions.
		once
			create Result.make_with_converter (create {TODOBACKEND_CONVERTER})
		end

end
