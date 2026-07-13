note
	description: "Standalone todobackend server with SQLite storage."

class
	TODOBACKEND_SQLITE_SERVER

inherit
	WSF_DEFAULT_SERVICE [TODOBACKEND_SQLITE_EXECUTION]

create
	make

feature {NONE} -- Initialization

	make
		do
			set_service_option ("port", 8081)
			set_service_option ("verbose", True)
			make_and_launch
		end

end
