note
	description: "[
				application execution
			]"
	date: "$Date: 2016-10-21 17:45:18 +0000 (Fri, 21 Oct 2016) $"
	revision: "$Revision: 99331 $"

class
   RESTLY_API_SERVER_EXECUTION


inherit



	WSF_ROUTED_EXECUTION

	WSF_ROUTED_URI_TEMPLATE_HELPER

create
	make

feature {NONE} -- Initialization




feature -- Router

	setup_router
			-- Setup `router'
		local
      fhdl: WSF_FILE_SYSTEM_HANDLER
      service_proxy: SERVICE_PROXY[JSON_OBJECT]
		do
			-- Exposing a SCOOP-enabled REST service
            create service_proxy

				map_uri_template ("/people{/id}",
					create {RESTLY_EWF_HANDLER}.make (service_proxy),
					router.methods_GET + router.methods_PUT + router.methods_POST)

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
