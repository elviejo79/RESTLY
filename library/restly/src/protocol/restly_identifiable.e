note
	description: "[
		Mixin: the object carries an identity key of type K.
		Stores that mint keys on insert (ABEL, autoincrement)
		use `set_id` to write the minted key back; client code
		reads `id` but never sets it.
	]"

deferred class
	RESTLY_IDENTIFIABLE [K]

feature -- Access

	id: K
			-- Identity key.
		deferred
		end

feature {RESTLY_TABLE_ORIGIN} -- Element Change

	set_id (a_id: K)
			-- Set `id` to `a_id`.
		deferred
		ensure
			id_set: id = a_id
		end

end
