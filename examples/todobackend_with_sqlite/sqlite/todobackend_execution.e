note
	description: "Declares the routes of the todobackend, backed by SQLite."

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
			-- connection thread would get its own store.
			-- ponytail: file db with pre-built schema (ABEL does not create
			-- tables); ":memory:" once schema bootstrap exists.
		once ("PROCESS")
			create Result.make ({SCHEME}.sqlite ("todobackend.db") / {TODO_ROW})
		end

end
