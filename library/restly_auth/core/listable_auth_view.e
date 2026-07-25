note
	description: "[
		The view keeps its back's verb set (M1b): a listable back
		wrapped in a bare view would answer 405 on list, and an
		unfiltered listing is precisely the leak Idea 3 forbids.
		`new_cursor` yields only keys the capability permits reading;
		`wipe_out` empties your world — invisible rows survive in the
		back.
	]"

class
	LISTABLE_AUTH_VIEW [K -> HASHABLE, V]

inherit
	AUTH_VIEW [K, V]
		redefine
			make
		end

	RESTLY_LISTABLE [K, V]

create
	make

feature {NONE} -- Initialization

	make (a_cap: CAPABILITY; a_back: RESTLY_LISTABLE [K, V])
		do
			Precursor (a_cap, a_back)
		end

feature -- Access

	new_cursor: TABLE_ITERATION_CURSOR [V, K]
			-- Only the keys this capability may read.
		do
			create {AUTH_FILTER_CURSOR [K, V]} Result.make (listable_back.new_cursor, capability)
		end

feature -- Removal

	wipe_out
			-- Empty this capability's world; invisible rows survive.
		local
			l_cursor: TABLE_ITERATION_CURSOR [V, K]
			l_keys: ARRAYED_LIST [K]
		do
			create l_keys.make (8)
			from
				l_cursor := new_cursor
			until
				l_cursor.after
			loop
				l_keys.extend (l_cursor.key)
				l_cursor.forth
			end
			from
				l_keys.start
			until
				l_keys.after
			loop
				remove (l_keys.item)
				l_keys.forth
			end
		end

feature {NONE} -- Implementation

	listable_back: RESTLY_LISTABLE [K, V]
			-- `back`, with the verb set the invariant certifies.
		do
			check back_is_listable: attached {RESTLY_LISTABLE [K, V]} back as l then
				Result := l
			end
		end

invariant
	back_is_listable: attached {RESTLY_LISTABLE [K, V]} back

end
