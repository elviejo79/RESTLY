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

	pico_table: PICO_TABLE[JSON_OBJECT]
		once
			create Result.make(10)
		end

feature -- Router

	setup_router
			-- Setup `router'
		local
      l_pico_http_server: PICO_HTTP_SERVER
		do
			-- Exposing a HTTPico REST service
           create l_pico_http_server.make(pico_table)
              map_uri_template ("/todos{/id}",
                create {PICO_HTTP_SERVER}.make (pico_table),
				    router.methods_GET + router.methods_PUT + router.methods_POST + router.methods_DELETE)

				--| As example:
				--|   /doc is dispatched to self documentated page
				--|   /* are dispatched to serve files/directories contained in "www" directory

				--| Self documentation
			router.handle ("/doc", create {WSF_ROUTER_SELF_DOCUMENTATION_HANDLER}.make (router), router.methods_GET)

			-- 	--| Files publisher
			-- create fhdl.make_hidden ("www")
			-- fhdl.set_directory_index (<<"index.html">>)
			-- router.handle ("", fhdl, router.methods_GET)


		end

end
