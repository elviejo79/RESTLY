note
	description: "HTTP client specialized for Todo Backend API"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TODOBACKEND_API

inherit
	PICO_HTTP_CLIENT [TODO_ITEM]
	export {NONE}
		make
	redefine
		force
	end

create
   make,
	make_default

feature

    make_default
        local
            todo_api_uri: URI
        do
            -- create todo_api_uri.make_from_string 
        -- ("https://todo-api.fanoutapp.com/todos/default/items/")
        create todo_api_uri.make_from_string ("http://localhost:3000/")
        make (todo_api_uri)
        end

feature -- Todo-specific implementation

	extract_id_from_response (a_response: HTTP_CLIENT_RESPONSE): detachable PATH_PICO
			-- Extract ID from response Location header or body
			-- Todo API specific: looks for "items/" path and "id" field
		local
			location: detachable STRING
			json_response: detachable JSON_OBJECT
		do
			if attached get_location_header (a_response) as l_location then
				location := l_location
			end

			-- Try to extract ID from Location header first
			if attached location as loc and then not loc.ends_with ("items/") then
				-- Extract path from full URL if necessary
				-- Handle both http://... and https://... in location header
				if loc.starts_with ("http://") or loc.starts_with ("https://") then
					-- Location is a full URL, extract just the ID with trailing slash
					if loc.has_substring ("items/") then
						Result := create {PATH_PICO}.make_from_string (loc.substring (loc.substring_index ("items/", 1) + 6, loc.count))
					else
						-- Fallback: extract everything after the domain
						Result := create {PATH_PICO}.make_from_string (loc.substring (loc.substring_index ("/", 1) + 2, loc.count))
					end
				else
					Result := create {PATH_PICO}.make_from_string (loc)
				end
			elseif attached a_response.body as body then
				-- Location header not useful, extract ID from response body JSON
				-- The body might contain HTTP headers from redirect, extract just the JSON part
				if body.has_substring ("{") then
					create json_response.make_from_string (body.substring (body.substring_index ("{", 1), body.count))
					if attached {JSON_STRING} json_response.item ("id") as id_value then
						Result := create {PATH_PICO}.make_from_string (id_value.unescaped_string_8 + "/")
					end
				end
			end
		end

	collection_extend (data: TODO_ITEM)
			-- Equivalent to http POST
			-- Creates new todo item and extracts ID from response
		local
			response: HTTP_CLIENT_RESPONSE
			l_postcondition: POSTCONDITION_VIOLATION
		do
			response := proxy.post ("", context_with_json, data.representation)
			io.put_string ("POST status: " + response.status.out + "%N")
			if attached get_location_header (response) as loc then
				io.put_string ("Location: " + loc + "%N")
			else
				io.put_string ("Location: none%N")
			end
			if attached response.body as b then
				io.put_string ("Body: " + b + "%N")
			else
				io.put_string ("Body: none%N")
			end
			if response.status < 400 then
				-- Success: extract ID from response
				if attached extract_id_from_response (response) as id then
					last_inserted_key := id
				else
					-- Set last_inserted_key to Void before raising exception
					last_inserted_key := Void
					create l_postcondition
					l_postcondition.raise
				end
			else
				-- Any error (4xx or 5xx): set to Void and raise postcondition
				last_inserted_key := Void
				create l_postcondition
				l_postcondition.raise
			end
		end

	force (data: TODO_ITEM; a_path: PATH_PICO)
			-- Update item at `a_path` with `data` using HTTP PATCH
			-- Redefined to use PATCH instead of PUT for Todo Backend API
		local
			response: HTTP_CLIENT_RESPONSE
			l_exception: POSTCONDITION_VIOLATION
			l_url: STRING_8
			retrieved: TODO_ITEM
		do
			l_url := build_absolute_url (a_path)
			io.put_string ("%N=== DEBUG force ===%N")
			io.put_string ("Sending data: " + data.representation + "%N")
			response := proxy.patch (l_url, context_with_json, data.representation)

			-- Follow redirect if needed
			if response.status >= 300 and response.status < 400 then
				if attached get_location_header (response) as loc then
					response := proxy.patch (loc, context_with_json, data.representation)
				end
			end

			if response.status /= 200 then
				create l_exception
			end

			io.put_string ("Response status: " + response.status.out + "%N")
			if attached response.body as body then
				io.put_string ("Response body: " + body + "%N")
			end

			retrieved := item (a_path)
			io.put_string ("Retrieved after PATCH: " + retrieved.representation + "%N")
			io.put_string ("Are they equal? " + (data ~ retrieved).out + "%N")
			io.put_string ("=== END DEBUG ===%N%N")

			last_inserted_key := a_path
		end

end
