note
	description: "[
		Todo store: hash table with server-minted keys (POST).
		PATCH merging and "url" derivation happen in the gateway.
	]"

class
	TODO_STORE

inherit
	RESOURCE_HASH_TABLE [STRING, JSON_OBJECT]
		redefine
			extend, make
		end

	RESTLY_POSTABLE [STRING, JSON_OBJECT]

	RESTLY_WIRE_SCHEMA

create
	make

feature {NONE} -- Initialization

	make (a_name: STRING)
			-- <Precursor>; declares the wire schema: "url" is derived
			-- by the gateway, never stored.
		do
			Precursor (a_name)
			url_field := "url"
		end

feature -- REST verbs

	extend (v: JSON_OBJECT; k: STRING)
			-- <Precursor>
			-- Defaults "completed" before storing.
		do
			if not v.has_key ("completed") then
				v.put (create {JSON_BOOLEAN}.make (False), "completed")
			end
			Precursor (v, k)
		end

feature {NONE} -- Key minting

	fresh_key (a_v: JSON_OBJECT): STRING
			-- <Precursor>: next unused counter key; ignores `a_v`.
			-- ponytail: O(n) probe from count+1; a counter attribute if stores grow large
		local
			i: INTEGER
		do
			from
				i := table.count + 1
			until
				not has_key (i.out)
			loop
				i := i + 1
			end
			Result := i.out
		end

end
