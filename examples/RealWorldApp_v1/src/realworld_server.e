note
	description: "Standalone RealWorld server."

class
	REALWORLD_SERVER

inherit
	WSF_DEFAULT_SERVICE [REALWORLD_EXECUTION]

create
	make

feature {NONE} -- Initialization

	make
		do
			set_service_option ("port", 8080)
			set_service_option ("max_concurrent_connections", 1)
			set_service_option ("verbose", True)
			make_and_launch
		end

end
