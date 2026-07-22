note
	description: "[
		Composable stage with two components: a `front` speaking
		[RK, RV] and the inherited `back` speaking [SK, SV].
		Composition (`<|`) comes from RESTLY_COMPOSABLE unchanged:
		twinning preserves `front`, appending re-backs the chain.
	]"

deferred class
	BINARY_COMBINATOR [RK -> HASHABLE, RV, SK -> HASHABLE, SV]

inherit
	RESTLY_COMPOSABLE [SK, SV]

feature -- Components

	front: RESTLY_PROTOCOL [RK, RV]
			-- Self-initialized to the null back end, like `back`.
		attribute
			Result := {RESTLY_NULL [RK, RV]}.instance
		end

feature -- Creation

	make (a_front: like front; a_back: like back)
		do
			front := a_front
			back := a_back
		end

end
