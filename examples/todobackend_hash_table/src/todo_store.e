note
	description: "[
		Todo store: hash table with server-minted keys (POST)
		and "url" field minting. PATCH merging happens in the gateway.
	]"

class
	TODO_STORE

inherit
	RESOURCE_HASH_TABLE [STRING, JSON_OBJECT]
		redefine
			extend
		end

	RESTLY_POSTABLE [STRING, JSON_OBJECT]

create
	make

feature -- REST verbs

	extend (v: JSON_OBJECT; k: STRING)
			-- <Precursor>
			-- Mints the element's "url" field before storing.
		local
			l_url: JSON_STRING
		do
			l_url := Base_url + "/" + k
			v.replace (l_url, "url")
			if not v.has_key ("completed") then
				v.put (create {JSON_BOOLEAN}.make (False), "completed")
			end
			Precursor (v, k)
		end

feature -- Key minting

	fresh_key: STRING
			-- <Precursor>
			-- ponytail: O(n) probe from count+1; a counter attribute if stores grow large
		local
			i: INTEGER
		do
			from
				i := count + 1
			until
				not has_key (i.out)
			loop
				i := i + 1
			end
			Result := i.out
		end

feature -- Representation

	Base_url: STRING = "http://localhost:8080/todos"
			-- Collection url minted into each element's "url" field
			-- (host and port must match {TODOBACKEND_SERVER}).

end
