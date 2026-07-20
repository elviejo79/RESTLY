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

feature -- Key minting

	fresh_key: INTEGER
			-- <Precursor>
		do
			Result := count + 1
		end

end
