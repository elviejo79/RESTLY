note
	description: "Summary description for {RESTLY_VERBS_EXTENDABLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	RESTLY_VERBS_EXTENDABLE[K->HASHABLE,V]

inherit
	RESTLY_VERBS_BASIC[K,V]

feature {NONE} --accessor
	append (v: V;request_id:INTEGER)
		-- Equivalent to http POST,
		-- Or in SQL equvilent to an INSERT in a Table that has an AUTO_INCREMENT id.
		-- The goal is that the client can append a new value, the server can create its own key and later the client can ask for the new key in `latest_appends`

		note
			modify: map
		require
			request_is_fresh: not latest_appends.has_key(request_id)
		deferred
		ensure
			map_effect: map |=| old map.updated (key_of(v),v)
			request_was_stored: latest_appends.has_key (request_id) and then latest_appends[request_id] = key_of(v)
		end

feature {NONE} -- Implementation
	gen_key_of(v:V):K
	deferred
	end

	key_of(v:V):K
	deferred
	end

	latest_appends: V_SORTED_TABLE[INTEGER,K]
	-- Because a Command / Query Separation 'append' can't return the key of the appended value.
	-- So each append request comes with a cliend provided request_id and then the client, can ask for the answer to its request.
	attribute
		create Result
	end


end
