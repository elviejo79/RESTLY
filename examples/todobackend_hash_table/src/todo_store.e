note
	description: "[
		Todo store: hash table with server-minted keys (POST),
		JSON merge (PATCH) and "url" field minting.
	]"

class
	TODO_STORE

inherit
	RESOURCE_HASH_TABLE [STRING, JSON_OBJECT]
		redefine
			extend
		end

	RESTLY_POSTABLE [STRING, JSON_OBJECT]

	RESTLY_PATCHABLE [STRING, JSON_OBJECT]

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

feature -- Update

	merge (a_patch: JSON_OBJECT; a_k: STRING)
			-- <Precursor>
		local
			l_item: JSON_OBJECT
		do
			l_item := item (a_k)
			across a_patch.current_keys as k loop
				l_item.replace (a_patch [k], k)
			end
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
