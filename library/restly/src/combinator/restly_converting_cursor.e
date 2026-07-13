note
	description: "[
		Table cursor that converts another cursor's keys and values
		on the fly: the pipeline front's stream, lazy end to end.
	]"

class
	RESTLY_CONVERTING_CURSOR [KR -> HASHABLE, R, KS -> HASHABLE, S]

inherit
	TABLE_ITERATION_CURSOR [R, KR]

create
	make

feature {NONE} -- Initialization

	make (a_inner: TABLE_ITERATION_CURSOR [S, KS]; a_key_converter: RESTLY_KEY_CONVERTER [KR, KS]; a_converter: RESTLY_CONVERTER [R, S])
			-- Stream over `a_inner`, converting with `a_key_converter` and `a_converter`.
		do
			inner := a_inner
			key_converter := a_key_converter
			converter := a_converter
		end

feature -- Access

	item: R
			-- <Precursor>
		do
			Result := converter.to_representation (inner.item)
		end

	key: KR
			-- <Precursor>
		do
			Result := key_converter.to_representation (inner.key)
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

	inner: TABLE_ITERATION_CURSOR [S, KS]
			-- Wrapped store cursor.

	key_converter: RESTLY_KEY_CONVERTER [KR, KS]
			-- Converts store keys to representation keys.

	converter: RESTLY_CONVERTER [R, S]
			-- Converts store values to representation values.

end
