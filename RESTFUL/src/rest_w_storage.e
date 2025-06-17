note
	description: "[
    {REST_W_STORAGE}.
    A contract representation of the http verbs. 
    to be used to define {REST_RESOURCES}
]"
	author: "Alejandro Garcia"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	REST_W_STORAGE [R, S ]
         -- [R]epresenation. For example JSON or XHTML
         -- [S]tored data. Could anything a binary, a database, or plain text file.
         -- What is important as that Clients only work with [R]s and the Server stores [S]s

feature -- http verbs

	item alias "[]" (key: URL_PATH):  R assign force
			-- equivalent to http GET
            -- Requests a resource representation; retrieves data only.
		require else
			key_must_exist: has_key (key)
		deferred
		ensure then
			error_500: Result /= void
				-- if we accepetd the request, we must return a value
		end

	has_key (key: URL_PATH): BOOLEAN
		-- equivalent to http HEAD
        -- Same as GET but without a response body
		deferred
		end

	extend(data:R; key: detachable URL_PATH)
        -- equivalent to http POST
        -- Submits data; may change state or cause side effects
		deferred
		ensure
			data_must_be_stored: attached item(last_inserted_key)
		end

	force (data:R; key: URL_PATH)
		-- equivalent to http PUT
        -- Replaces the resource's representation with the request content.
        require
            requested_a_known_key: has_key(key)
		deferred
		ensure then
			item_must_be_stored: attached item (key)
		end

	remove (key: URL_PATH)
		-- equivalent to http DELETE
        -- Removes the specified resource.
		deferred
		ensure then
			item_was_truly_eliminated: not has_key (key)
		end

	last_inserted_key: URL_PATH
         -- there is NO equivalent for this in http protocol.
         -- but is necessary to keep the Command / Query Separation principle in Eiffel
		attribute
			create Result.make_from_string ("")
		end
	trace (key: URL_PATH): detachable S
          -- equivalent to http TRACE
          -- Performs a loop-back diagnostic test. In our interpretation since this is debugging operation.
          -- It would return the actual [S]tored data.
		require
			must_be_stored: has_key (key)
			-- equivalent to http error 404 not found
		deferred
		ensure
			error_500_internal_server_error: Result /= void
				-- equivalent to http error 500 Internal Server Error
				-- if we accepetd the request, we must return a value
		end
end
