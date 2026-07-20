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
			make_and_launch
		end

end
