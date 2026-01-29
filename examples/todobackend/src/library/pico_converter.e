deferred class PICO_CONVERTER[R -> attached ANY, S -> attached ANY]
inherit
	PICO_VERBS[R]

feature -- Backend
backend: PICO_VERBS[S]
	deferred
	end

feature -- converters

to_representation(s:S):R
      deferred
      end
         
to_storage(r:R):S
      deferred
      end
         
to_storage_patch(a_representation_patch: like Patch_ds): like backend.patch_ds
      deferred
      end
  
         
feature -- Queries: http safe verbs

	item alias "/" (a_key: PATH): R assign force
			-- equivalent to http GET /{key}
		do
        Result:= to_representation(backend.item(a_key))
		end

	linear_representation: ARRAYED_LIST[R]
		do
			create Result.make(0)
			across backend.current_keys as k loop
				Result.extend(item(k))
			end
		end

	current_keys: ARRAY[PATH]
		do
			Result := backend.current_keys
		end

	has (a_key: PATH): BOOLEAN
			-- equivalent to http HEAD /{key}
		do
         Result := backend.has(a_key)
		end

feature -- Commands: http unsave verbs

	force (a_r: R; a_key: PATH)
		do
			backend.force(to_storage(a_r),a_key)
			last_modified_key := backend.last_modified_key
		end

	extend (a_r: R)
			-- equivalent to http POST /  the server must create the key
		do
			backend.extend(to_storage(a_r))
			last_modified_key := backend.last_modified_key
		end

	remove (a_key: PATH)
			-- equivalent to http DELETE /{id}
		do
        backend.remove(a_key)
		end

	wipe_out
			-- equvilante to http DELET /  everything
		do
        backend.wipe_out
		end

feature -- PATCH operations
patch_ds: detachable ANY
        -- This is the datastructure of incomplete data that we will
        -- use to do operations on incomplete data
      deferred
      end

         
	patch (a_patch: like patch_ds; a_key: PATH)
			-- equvilant to http PATCH /{key}
		do
			backend.patch(to_storage_patch(a_patch),a_key)
			last_modified_key := backend.last_modified_key
		end

	extend_from_patch (a_patch: like patch_ds)
			-- equvilante to a POST with incomplete data
		do
			backend.extend_from_patch(to_storage_patch(a_patch))
			last_modified_key := backend.last_modified_key
		end


feature -- Extra verbs

	key_for (a_r: R): PATH
			-- the server should know what the key for a new thing is
		do
			Result := backend.key_for(to_storage(a_r))
		end

end

   
