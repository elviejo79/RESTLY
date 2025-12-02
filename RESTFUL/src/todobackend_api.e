note
	description: "HTTP client specialized for Todo Backend API"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TODOBACKEND_API [R -> {JSON_OBJECT} create make_from_string, make_empty end]

inherit
	HTTP_SCHEME [R]

create
	make

feature -- Todo-specific implementation

	extract_id_from_response (a_response: HTTP_CLIENT_RESPONSE): detachable PATH_HTTPICO
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
						Result := create {PATH_HTTPICO}.make_from_string (loc.substring (loc.substring_index ("items/", 1) + 6, loc.count))
					else
						-- Fallback: extract everything after the domain
						Result := create {PATH_HTTPICO}.make_from_string (loc.substring (loc.substring_index ("/", 1) + 2, loc.count))
					end
				else
					Result := create {PATH_HTTPICO}.make_from_string (loc)
				end
			elseif attached a_response.body as body then
				-- Location header not useful, extract ID from response body JSON
				-- The body might contain HTTP headers from redirect, extract just the JSON part
				if body.has_substring ("{") then
					create json_response.make_from_string (body.substring (body.substring_index ("{", 1), body.count))
					if attached {JSON_STRING} json_response.item ("id") as id_value then
						Result := create {PATH_HTTPICO}.make_from_string (id_value.unescaped_string_8 + "/")
					end
				end
			end
		end

	collection_extend (data: R)
			-- Equivalent to http POST
			-- Creates new todo item and extracts ID from response
		local
			response: HTTP_CLIENT_RESPONSE
			l_precondition: PRECONDITION_VIOLATION
			l_postcondition: POSTCONDITION_VIOLATION
		do
			response := proxy.post ("", context_with_json, data.representation)
			if response.status < 400 then
				-- Success: extract ID from response
				if attached extract_id_from_response (response) as id then
					last_inserted_key := id
				else
					-- Set last_inserted_key to empty before raising exception
					last_inserted_key := create {PATH_HTTPICO}.make_from_string ("")
					create l_postcondition
				end
			elseif response.status < 500 then
				last_inserted_key := create {PATH_HTTPICO}.make_from_string ("")
				create l_precondition
			else
				last_inserted_key := create {PATH_HTTPICO}.make_from_string ("")
				create l_postcondition
			end
		end

end
