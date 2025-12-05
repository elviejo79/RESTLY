note
	description: "Example client application demonstrating how to use the HTTPico library"
	author: "Client Developer"
	date: "$Date$"
	revision: "$Revision$"

class
	MY_APPLICATION

inherit
	ARGUMENTS_32

create
	make

feature {NONE} -- Initialization

	make
			-- Run application demonstrating HTTPico library usage.
		do
			print ("=== My Application Using HTTPico Library ===%N%N")

			-- Example 1: Using REST_TABLE from the HTTPico library
			demonstrate_rest_table_usage

			print ("%N")

			-- Example 2: Working with URLs from the library
			demonstrate_url_usage

			print ("%N=== Application completed ===%N")
		end

feature {NONE} -- Examples

	demonstrate_rest_table_usage
			-- Show how to use REST_TABLE from the HTTPico library
		local
			api_endpoints: REST_TABLE[STRING]
			endpoint_path: URL_PATH
		do
			print ("1. Using REST_TABLE from HTTPico library:%N")

			-- Create a REST table to store API endpoint information
			create api_endpoints.make (20)

			-- Store some API endpoints
			create endpoint_path.make_from_string ("/users")
			api_endpoints[endpoint_path] := "Manages user accounts"

			create endpoint_path.make_from_string ("/products")
			api_endpoints[endpoint_path] := "Product catalog management"

			create endpoint_path.make_from_string ("/orders")
			api_endpoints[endpoint_path] := "Order processing system"

			-- Display the stored endpoints
			print ("   Stored API endpoints:%N")
			create endpoint_path.make_from_string ("/users")
			print ("   " + endpoint_path.out + " -> " + api_endpoints[endpoint_path] + "%N")

			create endpoint_path.make_from_string ("/products")
			print ("   " + endpoint_path.out + " -> " + api_endpoints[endpoint_path] + "%N")

			create endpoint_path.make_from_string ("/orders")
			print ("   " + endpoint_path.out + " -> " + api_endpoints[endpoint_path] + "%N")
		end

	demonstrate_url_usage
			-- Show how to use URL classes from the HTTPico library
		local
			base_url: URL
			api_url: URL
		do
			print ("2. Using URL classes from HTTPico library:%N")

			-- Create URLs using the library's URL class
			create base_url.make_from_string ("https://api.mycompany.com")
			create api_url.make_from_string ("https://api.mycompany.com/v1/users")

			print ("   Base URL: " + base_url.out + "%N")
			print ("   API URL: " + api_url.out + "%N")

			-- You could extend this to use other HTTPico library features like:
			-- - HTTP client operations
			-- - JSON parsing
			-- - Resource management
			print ("   (This demonstrates basic URL handling from the HTTPico library)%N")
		end

end
