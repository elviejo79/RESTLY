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
		do
			-- | exposing a dictionary

				map_uri_template ("/people{/id}",
					create {RESTLY_EWF_HANDLER}.make (people),
					router.methods_GET + router.methods_PUT + router.methods_POST)

            -- map_uri_template ("/people/",
				-- 	create {RESTFUL_HANDLER}.make (people),
				-- 	router.methods_GET + router.methods_POST)

				-- map_uri_template ("/people",
				-- 	create {RESTFUL_HANDLER}.make (people),
				-- 	router.methods_POST)


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
feature -- | Database (or state preserving variable)


people: REST_TABLE[JSON_OBJECT]
-- Shared table instance, initialized once and accessible across all requests
		local
			alice_path, bob_path: URL_PATH
		once
			-- Result := {RESOURCE_TABLE[JSON_OBJECT]}.make_and_register("http://localhost/my_table")
			create alice_path.make_from_string ("/alice")
			create bob_path.make_from_string ("/bob")
			create Result.make (10)
			Result [alice_path] := create {JSON_OBJECT}.make_with_capacity (2)
			Result [alice_path].put_string ("alice", "name")
			Result [alice_path].put_integer (20, "age")
			Result [bob_path] := create {JSON_OBJECT}.make_with_capacity (2)
			Result [bob_path].put_string ("bob", "name")
			Result [bob_path].put_integer (30, "age")
		end



end
