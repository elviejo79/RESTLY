note
	description: "Table cursor streaming an EiffelBase2 V_MAP_ITERATOR."

class
	RESTLY_V_MAP_CURSOR [K -> HASHABLE, V]

inherit
	TABLE_ITERATION_CURSOR [V, K]

create
	make

feature {NONE} -- Initialization

	make (a_inner: V_MAP_ITERATOR [K, V])
			-- Stream over `a_inner`.
		do
			inner := a_inner
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
		end

feature {NONE} -- Implementation

	inner: V_MAP_ITERATOR [K, V]
			-- Wrapped map iterator.

end
