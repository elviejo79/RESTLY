note
	description: "[
			Summary description for {PICO_VERBS}.
			R is for Representation the data type that the client would use to communicate
			P is for Patch the incomplete data that we would use for patch operations
			should be a sub-set of R but not mandatory.
		]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	PICO_VERBS [R -> attached ANY]

feature -- Queries: http safe verbs

	item alias "/" (key: PATH): R assign force
			-- equivalent to http GET /{key}
		require
			requested_a_known_key_or_throw_404_not_found: has (key)
		deferred
		end

	linear_representation:ARRAYED_LIST[R]
		deferred
		end

   current_keys: ARRAY[PATH]
      deferred
      end
         
	has (key: PATH): BOOLEAN
			-- equivalent to http HEAD /{key}
		deferred
		end

feature -- Commands: http unsave verbs

	force (v: R; key: PATH)
			-- equivalent to http PUT /{key}
		require
			key_exists_or_error_404_not_found: has (key)
		deferred
		ensure
			we_updated_the_last_key: key ~ last_modified_key
		end

	extend (v: R)
			-- equivalent to http POST /  the server must create the key
		deferred
		ensure
			new_value_is_set_or_error_500: v ~ item (last_modified_key)
		end

	remove (key: PATH)
			-- equivalent to http DELETE /{id}
		deferred
		end

	wipe_out
			-- equvilante to http DELET /  everything
		deferred
		end


feature -- PATCH operations
patch_ds: detachable ANY
        -- This is the datastructure of incomplete data that we will
        -- use to do operations on incomplete data
      deferred
      end
         
	patch (a_patch: like patch_ds; key: PATH)
			-- equvilant to http PATCH /{key}
		deferred
		end

	extend_from_patch (a_patch: like patch_ds)
			-- equvilante to a POST with incomplete data
		deferred
		end

feature -- Extra verbs
   last_modified_key: PATH
      attribute
        create Result.make_from_string ("")
      end

	key_for (v: R): PATH
			-- the server should know what the key for a new thing is
		deferred
		end

end
