note
	description: "[
		Converter for typed representations. Written once; works for every
		R that inherits RESTLY_REPRESENTATION [S] and exports
		`make_from_store' for creation. No agents, no reflection: the
		conversion knowledge lives in the representation class itself, and
		the creation constraint carries it into generic scope statically.

		DOCUMENTED LIMITATION (`is_representable'): the representable
		judgment lives as instance state of R, and no R instance exists
		when the query is asked about an S. Within a closed pipeline this
		is sound: `to_store''s postcondition guarantees everything entering
		storage is representable. For PRE-POPULATED or SHARED stores this
		default over-promises, and unrepresentable stored values surface
		inside `make_from_store' (postcondition/invariant tier) instead of
		as a precondition. Named trade-off; goes in the thesis Evaluation
		section, not under the rug.
	]"
	author: "agarciafdz@gmail.com"

class
	RESTLY_REPRESENTATION_CONVERTER [R -> RESTLY_REPRESENTATION [S] create make_from_store end, S]

inherit
	RESTLY_CONVERTER [R, S]

feature -- Conversion

	to_store (a_representation: R): S
			-- <Precursor>
		do
			Result := a_representation.to_store
		end

	to_representation (a_store: S): R
			-- <Precursor>
			-- Legal creation of a formal generic instance: licensed by the
			-- creation constraint on R.
		do
			create Result.make_from_store (a_store)
		end

end
