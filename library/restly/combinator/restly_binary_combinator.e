note
	description: "[
		Composable stage born with an attached `front` speaking [K, V].
		The inherited `back` speaks [HASHABLE, ANY]: the front must not
		know its backend's types; only `<|` wiring learns them, and a
		non-conforming backend fails loud at the descendant's read seam.
	]"

deferred class
	RESTLY_BINARY_COMBINATOR [K -> HASHABLE, V -> ANY]

inherit
	RESTLY_UNARY_COMBINATOR [HASHABLE, ANY]

feature -- Components

	front: RESTLY_PROTOCOL [K, V]
			-- Attached: every binary combinator is born fronted.

feature {NONE} -- Initialization

	make (a_front: like front)
			-- Stage fronted by `a_front`; back unwired until `<|`.
		do
			front := a_front
		end

end
