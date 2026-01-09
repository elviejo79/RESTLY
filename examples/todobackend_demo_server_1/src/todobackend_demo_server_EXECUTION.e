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

	todos_storage: PICO_CACHE [TODO_ITEM, STRING]
			-- Cache with PICO_TABLE frontend and FILE_CLIENT backend
		local
			table_cache: PICO_TABLE [TODO_ITEM]
			file_backend: PICO_FILE_CLIENT [STRING]
			file_uri: FILE_URL
			string_mapper: TODO_ITEM_STRING_MAPPER
		once
			-- Create in-memory cache (fast)
			create table_cache.make (100)

			-- Create file backend (slow, persistent)
			create file_uri.make_from_string ("file:///tmp/todos-backend")
			create file_backend.make (file_uri)

			-- Create mapper for TODO_ITEM <-> STRING conversion
			create string_mapper.make

			-- Create cache with write-through + cache-aside pattern
			create Result.make (table_cache, file_backend, string_mapper)
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
			json_converter: TODO_ITEM_CONVERTER
		do
			-- Create JSON converter that wraps the cache
			create json_converter.make
			json_converter.set_store (todos_storage)

			-- Create router with the converter
			create todo_router.make (json_converter)

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
