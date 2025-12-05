note
	description: "HTTPico example application - demonstrates library usage"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS_32

create
	make

feature {NONE} -- Initialization

	make
			-- Run application demonstrating HTTPico library features.
		do
			print ("=== HTTPico Library Example Application ===%N%N")

			-- Demonstrate REST_TABLE usage
			demonstrate_rest_table

			print ("%N")

			-- Demonstrate RESOURCE_TABLE usage
			demonstrate_resource_table

			print ("%N=== Example completed ===%N")
		end

feature {NONE} -- Demonstrations

	demonstrate_rest_table
			-- Demonstrate REST_TABLE functionality
		local
			table: REST_TABLE[STRING]
		do
			print ("1. Demonstrating REST_TABLE:%N")

			create table.make (10)

			-- Store some values
			table["/api/users"] := "User management endpoint"
			table["/api/products"] := "Product catalog endpoint"
			table["/api/orders"] := "Order processing endpoint"

			print ("   Stored endpoints in REST_TABLE%N")
			print ("   /api/users -> " + table["/api/users"] + "%N")
			print ("   /api/products -> " + table["/api/products"] + "%N")
			print ("   /api/orders -> " + table["/api/orders"] + "%N")
		end

	demonstrate_resource_table
			-- Demonstrate RESOURCE_TABLE functionality
		local
			table1, table2: RESOURCE_TABLE[STRING]
			url1, url2: URI_PICO
		do
			print ("2. Demonstrating RESOURCE_TABLE:%N")

			create url1.make_from_string("http://api.example.com")
			create url2.make_from_string("http://api.example.com")

			table1 := {RESOURCE_TABLE[STRING]}.make_and_register(url1)
			table2 := {RESOURCE_TABLE[STRING]}.make_and_register(url2)

			-- Store value in first table using backslash format like in tests
			table1["\data"] := "Shared resource data"

			print ("   Stored '\data' in first table%N")
			print ("   Value from first table: " + table1["\data"] + "%N")

			-- Check if key exists before accessing to avoid assertion violation
			if table2.has (create {URL_PATH}.make_from_string ("\data")) then
				print ("   Value from second table (same URL): " + table2["\data"] + "%N")
				print ("   Tables share the same resource: " + (table1["\data"] = table2["\data"]).out + "%N")
			else
				print ("   Second table does not have '\data' key - this indicates the resource sharing is not working%N")
				print ("   This suggests the RESOURCE_TABLE implementation needs review%N")
			end
		end

end
