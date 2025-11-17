note
	description: "[
    {RESTLY_NEW}.
    A Design By Contract interpreation of the HTTP Verbs.

    * [R]epresenation. For example JSON or XHTML
    * [U]RIs the ids of the resource we looking for

    Used os the common interface for all the components that are Storage Combinators.
]"
	author: "Alejandro Garcia"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	RESTLY_NEW [R, U]

feature -- Queries aka Http safe verbs

	has_key (key: U): BOOLEAN
		-- Equivalent to http HEAD
        -- Same as GET but without a response body
		deferred
		ensure
			-- is_safe: old Current = Current
			   -- item (http head) shouldn't change the state of the resource
		end

	item alias "[]" (key: U):  R assign force
			-- Equivalent to http GET
            -- Requests a resource representation; retrieves data only.
		require else
			requested_a_known_key_or_throw_404_not_found: has_key (key)
		deferred
		ensure
			must_return_item_or_throw_500_internal_server_error: Result /= void
				-- if we accepetd the request, we must return a value
			-- is_safe: old Current = Current
			   -- item (http get) shouldn't change the state of the resource
		end

feature -- Commands aka Http unsafe verbs
    collection_extend(data:R)
        -- equivalent to http POST
        -- Submits data; may change state or cause side effects
		deferred
		ensure
			data_stored_or_throw_510_not_extended: attached last_inserted_key
			key_tracked: attached last_inserted_key as key implies has_key (key)
		end

	force (data:R; key: U)
		-- Equivalent to http PUT
        -- Replaces the resource's representation with the request content.
        -- if key didn't exist it stil inserts it
		deferred
		ensure then
			data_stored_or_throw_507_insuficient_storage: attached item (key)
			data_stored_and_retrivabe_or_throw_500_internal_server_error: data ~ item (key)
			key_tracked: last_inserted_key ~ key
			key_exists: attached last_inserted_key as k implies has_key (k)
		end


	remove (key: U)
		-- Equivalent to http DELETE
        -- Removes the specified resource.
		deferred
		ensure
			truly_eliminated_or_throw_500_internal_server_error: not has_key (key)
		end

feature -- helpers
	last_inserted_key: detachable U
         -- There is NO equivalent for this in http protocol.
         -- but is necessary to keep the Command / Query Separation principle in Eiffel
      deferred
		end

	has_item(data:R):BOOLEAN
	deferred
	ensure
			--is_safe: old Current = Current
			-- item (http head) shouldn't change the state of the resource
	end

end
