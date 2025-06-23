note
	description: "[
				application execution
			]"
	date: "$Date: 2016-10-21 17:45:18 +0000 (Fri, 21 Oct 2016) $"
	revision: "$Revision: 99331 $"

class
	EXAMPLE_STORE_ROUTER_EXECUTION


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
            my_rest_dir: DIRECTORY_RESOURCE
            store_router:STORE_ROUTER
		do
		    create my_rest_dir.make_with_url("file:///home/agaciafdz/exp_resources")
			create store_router.make_with("/exp_resources/", my_rest_dir)

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
