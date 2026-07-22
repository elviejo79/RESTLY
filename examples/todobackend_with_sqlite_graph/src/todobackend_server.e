note
	description: "Standalone todobackend server."

class
	TODOBACKEND_SERVER

inherit
	WSF_DEFAULT_SERVICE [TODOBACKEND_EXECUTION]

create
	make

feature {NONE} -- Initialization

	make
		do
			set_service_option ("port", 8080)
			set_service_option ("verbose", True)
			-- ponytail: one worker — shared ABEL/SQLite repository is not
			-- thread-safe (segfaults under concurrent requests); guard the
			-- repository with a mutex if throughput ever matters.
			set_service_option ("max_concurrent_connections", 1)
			make_and_launch
		end

end
