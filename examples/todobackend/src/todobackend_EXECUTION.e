note
	description: "[
				application execution
			]"
	date: "$Date$"
	revision: "$Revision$"

class
	TODOBACKEND_EXECUTION


inherit




	WSF_FILTERED_ROUTED_EXECUTION
  	WSF_ROUTED_URI_TEMPLATE_HELPER

create
	make

feature {NONE} -- Initialization

	db: PICO_PATH_TABLE[TODO_ITEM]
			-- Storage layer
		once ("PROCESS")
			create Result.make (10)
		end

	decorator: TODO_JSON_DECORATOR
			-- Adds URL field to JSON representations
		once ("PROCESS")
			create Result.make_with_backend (db, "http://localhost:8080/todos")
		end

	handler: PICO_JSON_HANDLER
			-- Generic JSON handler
		once ("PROCESS")
			create Result.make_with_backend (decorator)
		end


feature -- Filter

	create_filter
			-- Create `filter'
		do
				--| Example using Maintenance filter.
			create {WSF_MAINTENANCE_FILTER} filter
		end

	setup_filter
			-- Setup `filter'
		local
			f: like filter
		do
			create {WSF_CORS_FILTER} f
			f.set_next (create {WSF_LOGGING_FILTER})

				--| Chain more filters like {WSF_CUSTOM_HEADER_FILTER}, ...
				--| and your owns filters.

			filter.append (f)
		end


feature -- Router

	setup_router
			-- Setup `router'
		local
			fhdl: WSF_FILE_SYSTEM_HANDLER
		do

			-- Map /todos{/id} to PICO_JSON_HANDLER
		map_uri_template ("/todos{/id}", handler, methods_GET_POST_PATCH_DELETE)

			-- CORS preflight handling for OPTIONS on the same URI template
		map_uri_template_agent ("/todos{/id}", agent options_filter.execute, methods_OPTIONS)


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
feature -- helpers

	methods_GET_POST_PATCH_DELETE: WSF_REQUEST_METHODS
			-- Allowed methods for /todos{/id}
		once
			create Result.make (4)
			Result.enable_get
			Result.enable_post
			Result.enable_patch
			Result.enable_delete
			Result.lock
		end

	methods_OPTIONS: WSF_REQUEST_METHODS
			-- OPTIONS only, for CORS preflight
		once
			create Result
			Result.enable_options
			Result.lock
		end

	options_filter: WSF_CORS_OPTIONS_FILTER
			-- CORS OPTIONS filter
		once
			create Result.make (router)
		end


end
