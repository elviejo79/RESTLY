note
	description: "[
		Todo store: hash table of TODO_ROW with server-minted keys (POST).
		PATCH merging happens in the gateway, in wire format.
	]"

class
	TABLE_INTEGER_TODO_ROW

inherit
	RESOURCE_HASH_TABLE [INTEGER, TODO_ROW]
		redefine
			extend
		end

	RESTLY_POSTABLE [INTEGER, TODO_ROW]

create
	make

feature -- REST verbs

	extend (v: TODO_ROW; k: INTEGER)
			-- <Precursor>
			-- Writes the minted key into the row's identity.
		do
			v.set_id (k)
			Precursor (v, k)
		end

feature -- Extension

	extend_new (a_v: TODO_ROW; a_request_id: HASHABLE)
			-- <Precursor>
		local
			l_key: INTEGER
		do
			if not extend_requests.has_key (a_request_id) then
				l_key := fresh_key
				extend (a_v, l_key)
				extend_requests.extend (l_key, a_request_id)
			end
		end

feature {NONE} -- Key minting

	fresh_key: INTEGER
			-- Next unused key.
		do
			Result := table.count + 1
		end

end
