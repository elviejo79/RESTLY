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

create
	make

feature {NONE} -- Router

	setup_router
		do
			routes ["/todos"] := (create {GATEWAY}) <| (create {TODO_CODEC}) <| todos_table
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
