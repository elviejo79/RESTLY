note
	description: "[
				application execution
			]"
	date: "$Date$"
	revision: "$Revision$"

class
	TODOBACKEND_DEMO_SERVER_EXECUTION


inherit




WSF_FILTERED_ROUTED_EXECUTION
   WSF_ROUTED_URI_TEMPLATE_HELPER



create
	make

feature {NONE} -- Initialization

	todos_table: TODOS_TABLE
		once
			create Result.make_default
		end


feature -- Filter

	create_filter
			-- Create `filter'
		do
				-- Global CORS filter as first in the chain
			create {WSF_CORS_FILTER} filter
		end

	setup_filter
			-- Setup `filter'
		do
				-- Append maintenance and logging filters.
			filter.append (create {WSF_MAINTENANCE_FILTER})
			filter.append (create {WSF_LOGGING_FILTER})
		end

feature -- Router
	setup_router
		local
			todo_router: TODO_HTTP_SERVER
			converter: TODO_ITEM_CONVERTER
		do
			create converter.make
			create todo_router.make (converter)

				-- Main handler: allow specific methods on /todos and /todos/{id}
			map_uri_template ("/todos{/id}", todo_router, methods_GET_POST_PUT_DELETE_PATCH)

				-- CORS preflight handling for OPTIONS on the same URI template
			map_uri_template_agent ("/todos{/id}", agent options_filter.execute, methods_OPTIONS)
		end

feature {NONE} -- Methods helpers

   options_filter: WSF_CORS_OPTIONS_FILTER
      once
        create Result.make(router)
      end
      
	methods_GET_POST_PUT_DELETE_PATCH: WSF_REQUEST_METHODS
			-- Allowed methods for /todos{/id}
		once
			create Result.make (5)
			Result.enable_get
			Result.enable_post
			Result.enable_put
			Result.enable_delete
			Result.enable_patch
			Result.lock
		end

	methods_OPTIONS: WSF_REQUEST_METHODS
			-- OPTIONS only, for CORS preflight
		once
			create Result
			Result.enable_options
			Result.lock
		end

end
