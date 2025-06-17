note
	description: "[
				application execution
			]"
	date: "$Date: 2016-10-21 17:45:18 +0000 (Fri, 21 Oct 2016) $"
	revision: "$Revision: 99331 $"

class
	A_WEB_EXAMPLE_EXECUTION
	

inherit


  
	WSF_ROUTED_EXECUTION
  


create
	make

feature {NONE} -- Initialization




feature -- Router

	setup_router
			-- Setup `router'
		local
			fhdl: WSF_FILE_SYSTEM_HANDLER
		do
				--| As example:
				--|   /doc is dispatched to self documentated page
				--|   /* are dispatched to serve files/directories contained in "www" directory

				--| Self documentation
			router.handle ("/doc", create {WSF_ROUTER_SELF_DOCUMENTATION_HANDLER}.make (router), router.methods_GET)

				--| Files publisher
			create fhdl.make_hidden ("www")
			fhdl.set_directory_index (<<"index.html">>)
			router.handle ("", fhdl, router.methods_GET)
		end

end
