note
	description: "[
				A demo of the HTTPico Library. Implementing the todobackend.com benchmark
			]"
	date: "$Date$"
	revision: "$Revision$"

class
	TODOBACKEND_DEMO_SERVER


inherit
	WSF_LAUNCHABLE_SERVICE
		redefine
			initialize
		end
	APPLICATION_LAUNCHER [TODOBACKEND_DEMO_SERVER_EXECUTION]


create
	make_and_launch

feature {NONE} -- Initialization

	initialize
			-- Initialize current service.
		do
			Precursor
			set_service_option ("port", 8080)
			set_service_option ("verbose", "yes")
			set_service_option ("max_concurrent_connections",1)
         set_service_option ("socket_timeout", 5)
         set_service_option ("socket_recv_timeout",5)
         set_service_option ("allow_reuse_address", True)
		end


end
