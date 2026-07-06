note
	description: "[
		Mixin: iteration and bulk deletion.
		Separate from RESTLY_PROTOCOL, EiffelBase2-style
		container/iterator separation.
	]"

deferred class
	RESTLY_TRAVERSABLE [K -> HASHABLE, V]

inherit
	RESTLY_PROTOCOL [K, V]

	ITERABLE [V]
		undefine
			is_equal, copy, out, default_create
		end

feature -- Iteration

	new_cursor: V_MAP_ITERATOR [K, V]
			-- Iterator exposing both keys and values.
		deferred
		end

	count: INTEGER
			-- Number of entries.
		deferred
		end

feature -- Removal

	wipe_out
			-- Remove all entries.
		deferred
		ensure
			empty: count = 0
		end

end
