note
	description: "[
		Table cursor streaming an executed PS_QUERY.
		Keys are the row ids carried by the objects themselves.
		Closes the query once the stream is exhausted.
	]"

class
	RESTLY_TABLE_CURSOR [V -> RESTLY_IDENTIFIABLE [INTEGER]]

inherit
	TABLE_ITERATION_CURSOR [V, INTEGER]

create
	make

feature {NONE} -- Initialization

	make (a_query: PS_QUERY [V])
			-- Stream over already-executed `a_query`.
		do
			query := a_query
			inner := a_query.new_cursor
			release_if_exhausted
		end

feature -- Access

	item: V
			-- <Precursor>
		do
			Result := inner.item
		end

	key: INTEGER
			-- <Precursor>
		do
			Result := inner.item.id
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
			release_if_exhausted
		end

feature {NONE} -- Implementation

	query: PS_QUERY [V]
			-- Source query; owns the database resources.

	inner: ITERATION_CURSOR [V]
			-- The query's streaming cursor.

	is_released: BOOLEAN
			-- Has `query` been closed?

	release_if_exhausted
			-- Close `query` once the stream is drained.
		do
			if inner.after and not is_released then
				query.close
				is_released := True
			end
		end

end
