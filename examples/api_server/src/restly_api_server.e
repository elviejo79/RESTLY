note
	description: "[
				application service
			]"
	date: "$Date: 2016-10-21 17:45:18 +0000 (Fri, 21 Oct 2016) $"
	revision: "$Revision: 99331 $"

class
	RESTLY_API_SERVER
	

inherit
	WSF_LAUNCHABLE_SERVICE
		redefine
			initialize
		end
	APPLICATION_LAUNCHER [RESTLY_API_SERVER_EXECUTION]
	

create
	make_and_launch

feature {NONE} -- Initialization

	initialize
			-- Initialize current service.
		do
			Precursor
			set_service_option ("port", 8080)
			set_service_option ("verbose", "yes")
         set_service_option ("is_persistent_connection_supported", True)
         set_service_option ("max_concurrent_connections", 10)
		end


end
