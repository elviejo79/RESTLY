note
	description: "[
		Concrete pipeline front for JSON web types.
		Web side: [STRING, JSON_OBJECT].
		merge = RFC 7386 JSON merge (absent field = unchanged).
		fresh_key = auto-increment INTEGER rendered as STRING.
	]"

class
	RESTLY_JSON_PIPELINE_FRONT [KS -> HASHABLE, S]

inherit
	RESTLY_PIPELINE_FRONT [STRING, JSON_OBJECT, KS, S]

create
	make

feature -- Key minting

	fresh_key: STRING
			-- Next auto-increment key rendered as STRING.
		do
			last_id := last_id + 1
			Result := last_id.out
		end

feature -- Update (RESTLY_PATCHABLE)

	merge (a_patch: JSON_OBJECT; a_k: STRING)
			-- RFC 7386: for each key in `a_patch', replace that key
			-- in the stored item; absent keys stay unchanged.
		local
			l_store_key: KS
			l_current: JSON_OBJECT
		do
			l_store_key := key_converter.to_store (a_k)
			l_current := converter.to_representation (store.item (l_store_key))
			across a_patch as ic loop
				l_current.replace (ic, @ ic.key)
			end
			store.put (converter.to_store (l_current), l_store_key)
		end

feature {NONE} -- Implementation

	last_id: INTEGER
			-- Counter for auto-increment keys.

end
