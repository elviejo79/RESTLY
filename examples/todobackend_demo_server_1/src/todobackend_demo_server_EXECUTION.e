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
				--| Example using Maintenance filter.
			create {WSF_MAINTENANCE_FILTER} filter
		end

	setup_filter
			-- Setup `filter'
		local
			f: like filter
     do
			create {WSF_LOGGING_FILTER} f

				--| Chain more filters like {WSF_CUSTOM_HEADER_FILTER}, ...
				--| and your owns filters.

			filter.append (f)
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
