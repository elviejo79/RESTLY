note
	description: "Wires the RESTLY pipeline to EWF with a SQLite backend."

class
	TODOBACKEND_SQLITE_EXECUTION

inherit
	RESTLY_EWF_MOUNTING

create
	make

feature {NONE} -- Router

	setup_router
		do
			mount_resource ("/todos", todo_pipeline)
			print_pipeline_graph
		end

feature {NONE} -- Diagnostics

	print_pipeline_graph
			-- Dump the composition as GraphViz dot (first request only).
		once ("PROCESS")
			io.put_string (todo_pipeline.graph_description)
		end

feature {NONE} -- Pipeline

	todo_pipeline: RESTLY_PIPELINE_FRONT [STRING, JSON_OBJECT, INTEGER, TODO_ROW]
			-- JSON front → RESTLY_TABLE_ORIGIN → SQLite.
		once ("PROCESS")
			create {TODOBACKEND_PIPELINE} Result.make (todo_table)
		end

	todo_table: RESTLY_TABLE_ORIGIN [TODO_ROW]
			-- SQLite table storing TODO_ROW objects.
		once ("PROCESS")
			bootstrap_schema
			create Result.make ({RESTLY_SCHEME}.sqlite (db_file) / {TODO_ROW})
		end

feature {NONE} -- Database

	db_file: STRING = "todobackend.db"
			-- SQLite database file.

	bootstrap_schema
			-- Create the table if the database does not exist.
		local
			l_db: SQLITE_DATABASE
		once ("PROCESS")
			if not (create {RAW_FILE}.make_with_name (db_file)).exists then
				create l_db.make_create_read_write (db_file)
				(create {SQLITE_MODIFY_STATEMENT}.make ("CREATE TABLE todo_row (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, completed INTEGER, order_value INTEGER);", l_db)).execute
				l_db.close
			end
		end

end
