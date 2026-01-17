note
	description: "[
				application service
			]"
	date: "$Date$"
	revision: "$Revision$"

class
	TODOBACKEND


inherit
	WSF_LAUNCHABLE_SERVICE
		redefine
			initialize
		end
	APPLICATION_LAUNCHER [TODOBACKEND_EXECUTION]


create
	make_and_launch

feature {NONE} -- Initialization

	initialize
			-- Initialize current service.
		do
			Precursor
			set_service_option ("port", 8080)
			set_service_option ("verbose", "yes")
			set_service_option ("max_concurrent_connections", 10)
		end


end
