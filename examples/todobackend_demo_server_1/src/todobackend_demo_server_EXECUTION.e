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

	my_todos: TODO_STORAGE
		once
			create Result.make_default
		end


feature -- Filter

	create_filter
			-- Create `filter'
		do
			create {WSF_MAINTENANCE_FILTER} filter
		end

	setup_filter
			-- Setup `filter'
		do
				-- Maintenance filter is created in `create_filter'.
				-- Append CORS and logging filters.
			filter.append (create {TODO_CORS_FILTER})
			filter.append (create {WSF_LOGGING_FILTER})
		end

feature -- Router
	setup_router
		local
			todo_router: PICO_HTTP_SERVER[JSON_VALUE,TODO_ITEM]
			converter: TODO_ITEM_CONVERTER
		do
			create converter.make
			create todo_router.make (my_todos, converter)

			map_uri_template ("/todos{/id}", todo_router, Void)
		end

end
