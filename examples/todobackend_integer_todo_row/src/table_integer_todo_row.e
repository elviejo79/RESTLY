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
			extend, fresh_key
		end

create
	make

feature -- REST verbs

	extend (v: TODO_ROW; k: INTEGER)
			-- <Precursor>
			-- Writes the minted key into the row's identity.
		do
			v.id := k
			Precursor (v, k)
		end

feature {RESTLY_PROTOCOL} -- Key minting

	fresh_key (a_v: TODO_ROW): INTEGER
			-- <Precursor>: next unused counter key; ignores `a_v`.
		do
			Result := table.count + 1
		end

end
