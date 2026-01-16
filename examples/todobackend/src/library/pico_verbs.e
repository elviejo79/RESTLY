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
	PICO_VERBS [R -> attached ANY, P]

feature -- Queries: http safe verbs

	item alias "/" (key: PATH): R assign force
			-- equivalent to http GET /{key}
		deferred
		end

	linear_representation:LIST[R]
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
			new_value_is_set_or_erro_500: v ~ item (last_modified_key)
		end

	patch (a_patch: P; key: PATH)
			-- equvilant to http PATCH /{key}
		deferred
		end

	extend_from_patch (a_patch: P)
			-- equvilante to a POST with incomplete data
		deferred
		end

	remove (key: PATH)
			-- equivalent to http DELETE /{id}
		deferred
		end

	wipe_out
			-- equvilante to http DELET /  everything
		deferred
		end

feature -- Extra verbs
	last_modified_key: PATH

	key_for (v: R): PATH
			-- the server should know what the key for a new thing is
		deferred
		end

end
