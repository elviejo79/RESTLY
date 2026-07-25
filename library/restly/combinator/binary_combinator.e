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

	detachable_front: detachable RESTLY_PROTOCOL [RK, RV]
			-- The front stage; Void until wired, stable like `detachable_back`.
		note
			option: stable
		attribute
		end

	front: RESTLY_PROTOCOL [RK, RV]
			-- The wired front; certification point mirroring `back`.
		require
			fronted: attached detachable_front
		do
			check fronted: attached detachable_front as l then
				Result := l
			end
		end

feature -- Creation

	make (a_front: like front; a_back: like back)
		do
			detachable_front := a_front
			detachable_back := a_back
		end

end
