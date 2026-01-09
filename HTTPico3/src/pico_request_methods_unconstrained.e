deferred class PICO_REQUEST_METHODS_UNCONSTRAINED[R]

feature -- Queries aka HTTP safe methods

    has(key: PATH_PICO):BOOLEAN
        -- equivalent of http head /{key}
        deferred
        end
        
	item alias "[]" (key: PATH_PICO): R assign force
			-- Equivalent to http GET /key
			-- Requests a resource representation; retrieves data only.
		require
			requested_a_known_key_or_throw_404_not_found: has (key)
        deferred
        end
    
    linear_representation: LIST[R]
      -- Equivalent to http GET /  to list all items in an array
      deferred
      end

	key_for (data: R): PATH_PICO
			-- Returns the key for the given data item
		deferred
		end

	options: LIST[STRING]
			-- Returns supported HTTP methods/options
		deferred
		end


feature -- Commands aka Http unsafe verbs
   
   extend (data: R)
			-- equivalent to http POST
			-- Submits data; may change state or cause side effects
		deferred
		ensure
			data_stored_or_throw_510_not_extended: attached last_inserted_key
			key_tracked: attached last_inserted_key as key implies has(key)
		end

	force (data: R; key: PATH_PICO)
			-- Equivalent to http PUT
			-- Replaces the resource's representation with the request content.
			-- if key didn't exist it stil inserts it
		deferred
		ensure then
			data_stored_or_throw_507_insuficient_storage: attached item (key)
			data_stored_and_retrivabe_or_throw_500_internal_server_error:
			(data ~ item (key)) or else
			(if attached {JSON_VALUE} data as jv_data and attached {JSON_VALUE} item(key) as jv_item then
				jv_data.representation ~ jv_item.representation
			else
				False
			end)
		end

	remove (key: PATH_PICO)
			-- Equivalent to http DELETE /{key}
			-- Removes the specified resource.
		deferred
		ensure
			truly_eliminated_or_throw_500_internal_server_error: not has(key)
		end

   wipe_out
   -- equivalent to http DELETE /
   -- thi method is dangerous probably shouldn't export it most of 
-- the time.
      deferred
      end
      
      is_empty:BOOLEAN
      deferred
      end
      
feature 

	extend_with_patch (a_patch: TABLE_ITERABLE [detachable ANY, STRING])
			-- Equivalent to http POST with PATCH data
			-- Creates a new resource using partial data from the patch
		deferred
		ensure
			data_stored_or_throw_510_not_extended: attached last_inserted_key
			key_tracked: attached last_inserted_key as key implies has(key)
		end

	patch (a_patch: TABLE_ITERABLE [detachable ANY, STRING]; key: PATH_PICO)
			-- Equivalent to http PATCH /{key}
			-- Partially modifies the resource's representation
		require
			requested_a_known_key_or_throw_404_not_found: has (key)
		deferred
		end


feature -- helpers
	last_inserted_key: PATH_PICO
			-- There is NO equivalent for this in http protocol.
			-- but is necessary to keep the Command / Query Separation principle in Eiffel
            attribute
                create Result.make_from_string("last_insert_id_default_value")
            end

end
