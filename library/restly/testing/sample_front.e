note
	description: "[
		Concrete RESTLY_PIPELINE_FRONT for testing.
		STRING keys/values on the web side,
		INTEGER keys and SAMPLE_ITEM on the store side.
		fresh_key = auto-increment INTEGER rendered as STRING.
		merge = simple title replacement (real merge tested on JSON front).
	]"

class
	SAMPLE_FRONT

inherit
	RESTLY_PIPELINE_FRONT [STRING, STRING, INTEGER, SAMPLE_ITEM]

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

	merge (a_patch: STRING; a_k: STRING)
			-- Simplest legal implementation: replace the title.
		local
			l_store_key: INTEGER
			l_item: SAMPLE_ITEM
		do
			l_store_key := key_converter.to_store (a_k)
			l_item := store.item (l_store_key)
			l_item.set_title (a_patch)
		end

feature {NONE} -- Implementation

	last_id: INTEGER
			-- Counter for auto-increment keys.

end
