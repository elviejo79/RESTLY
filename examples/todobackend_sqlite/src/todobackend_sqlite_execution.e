note
	description: "Wires the RESTLY pipeline to EWF with a SQLite backend."

class
	TODOBACKEND_SQLITE_EXECUTION

inherit
	RESTLY_EWF_SERVER

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

	todo_pipeline: RESTLY_JSON_PIPELINE_FRONT [INTEGER, TODO_ROW]
			-- JSON front → RESTLY_TABLE → SQLite.
		local
			l_keys: RESTLY_INT_KEY_CONVERTER
			l_json: TODOBACKEND_JSON_CONVERTER
		once ("PROCESS")
			create l_keys
			create l_json.make (agent: TODO_ROW do create Result.make_default end)
			create Result.make (todo_table, l_keys, l_json)
		end

	todo_table: RESTLY_TABLE [TODO_ROW]
			-- ABEL-backed table storing TODO_ROW objects.
		once ("PROCESS")
			create Result.make_with_repository (todo_repository)
		end

	todo_repository: PS_REPOSITORY
			-- ABEL repository managing TODO_ROW with primary key "id".
		local
			l_factory: PS_SQLITE_RELATIONAL_REPOSITORY_FACTORY
		once ("PROCESS")
			bootstrap_schema
			create l_factory.make
			l_factory.set_database (db_file)
			l_factory.manage ({TODO_ROW}, "id")
			Result := l_factory.new_repository
		end

feature {NONE} -- Database

	db_file: STRING = "todobackend.db"
			-- SQLite database file.

	bootstrap_schema
			-- Create the table if the database does not exist.
		local
			l_raw_file: RAW_FILE
			l_db: SQLITE_DATABASE
			l_modify: SQLITE_MODIFY_STATEMENT
		once ("PROCESS")
			create l_raw_file.make_with_name (db_file)
			if not l_raw_file.exists then
				create l_db.make_create_read_write (db_file)
				create l_modify.make ("CREATE TABLE todo_row (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, completed INTEGER, order_value INTEGER);", l_db)
				l_modify.execute
				l_db.close
			end
		end

end
