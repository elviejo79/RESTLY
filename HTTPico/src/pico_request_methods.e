note
	description: "[
			    {PICO_REQUEST_METHODS}.
			    A Design By Contract interpreation of the HTTP Verbs.
			
			    * [R]epresenation. For example JSON or XHTML
			    * [U]RIs the ids of the resource we looking for
			
			    Used os the common interface for all the components that are Storage Combinators.
		]"
	author: "Alejandro Garcia"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	PICO_REQUEST_METHODS [R -> PICO_DATA_OBJECT]

feature -- Queries aka Http safe verbs

	has_key (key: PATH_PICO): BOOLEAN
			-- Equivalent to http HEAD
			-- Same as GET but without a response body
		deferred
		ensure
				-- is_safe: old Current = Current
				-- item (http head) shouldn't change the state of the resource
		end

	item alias "[]" (key: PATH_PICO): R assign force
			-- Equivalent to http GET /key
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
      
      linear_representation: ARRAY_LIST[R]
      -- Equivalent to http GET /  to list all items in an array
      deferred
      end
         
      all_keys: ITERABLE [PATH_PICO]
			-- All keys in the storage
		deferred
		end

      -- items:HASH_TABLE[R:PATH_PICO]
      -- deferred
      -- end


feature -- Commands aka Http unsafe verbs
   
	extend_with_incomplete (data: like {R}.patch_data_type)
			-- equivalent to http POST
			-- Submits data; may change state or cause side effects
		deferred
		ensure
			data_stored_or_throw_510_not_extended: attached last_inserted_key
			key_tracked: attached last_inserted_key as key implies has_key (key)
		end

   extend (data: R)
			-- equivalent to http POST
			-- Submits data; may change state or cause side effects
		deferred
		ensure
			data_stored_or_throw_510_not_extended: attached last_inserted_key
			key_tracked: attached last_inserted_key as key implies has_key (key)
		end

	force (data: R; key: PATH_PICO)
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

   patch(incomplet_data : TUPLE)
      deferred
      end
         
	remove (key: PATH_PICO)
			-- Equivalent to http DELETE /{key}
			-- Removes the specified resource.
		deferred
		ensure
			truly_eliminated_or_throw_500_internal_server_error: not has_key (key)
		end

   wipe_out
   -- equivalent to http DELETE /
   -- thi method is dangerous probably shouldn't export it most of 
-- the time.
      deferred
      ensure
         nothing_remains_stored: all_keys.is_empty
      end
      
feature -- helpers
	last_inserted_key: detachable PATH_PICO
			-- There is NO equivalent for this in http protocol.
			-- but is necessary to keep the Command / Query Separation principle in Eiffel
		deferred
		end

	has_item (data: R): BOOLEAN
		do
			Result := True
		ensure
				--is_safe: old Current = Current
				-- item (http head) shouldn't change the state of the resource
		end

      
end
