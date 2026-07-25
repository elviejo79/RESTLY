note
	description: "[
		Forward-only cursor over a backing store's cursor, skipping
		keys the capability cannot read: the catalog you see is your
		permission set (Idea 3, M1b).
	]"

class
	AUTH_FILTER_CURSOR [K -> HASHABLE, V]

inherit
	TABLE_ITERATION_CURSOR [V, K]

create
	make

feature {NONE} -- Initialization

	make (a_inner: TABLE_ITERATION_CURSOR [V, K]; a_capability: CAPABILITY)
		do
			inner := a_inner
			capability := a_capability
			skip_forbidden
		end

feature -- Access

	item: V
			-- <Precursor>
		do
			Result := inner.item
		end

	key: K
			-- <Precursor>
		do
			Result := inner.key
		end

feature -- Status report

	after: BOOLEAN
			-- <Precursor>
		do
			Result := inner.after
		end

feature -- Cursor movement

	forth
			-- <Precursor>
		do
			inner.forth
			skip_forbidden
		end

feature {NONE} -- Implementation

	skip_forbidden
			-- Advance `inner` past keys this capability cannot read.
		do
			from
			until
				inner.after or else capability.readable (inner.key)
			loop
				inner.forth
			end
		end

	inner: TABLE_ITERATION_CURSOR [V, K]

	capability: CAPABILITY

end
