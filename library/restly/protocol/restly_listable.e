note
	description: "[
		Mixin: iteration and bulk deletion.
		Separate from RESTLY_PROTOCOL, EiffelBase2-style
		container/iterator separation.
	]"

deferred class
	RESTLY_LISTABLE [K -> HASHABLE, V]

inherit
	RESTLY_PROTOCOL [K, V]

	TABLE_ITERABLE [V, K]
			-- `new_cursor: TABLE_ITERATION_CURSOR [V, K]` comes from
			-- here: a forward-only stream exposing both keys and values.
		undefine
			is_equal, copy, out, default_create
		end

feature -- Removal

	wipe_out
			-- Remove all entries.
		deferred
		ensure
			empty: new_cursor.after
		end

end
