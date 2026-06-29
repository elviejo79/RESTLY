note
	description: "[
	{RESTLY_COMBINATOR_DIADIC}
	The mother combinator for all the combinators that will use a frontend and a backend. like cache_combinator. etc.
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	RESTLY_COMBINATOR_DIADIC[K->HASHABLE, F, B]

inherit
	RESTLY_COMBINATOR_DETACHABLE[K, F]
		rename
			make as make_with_front
		redefine
			as_combinator
		end

feature {NONE} -- Implementation

	backend: RESTLY_VERBS_BASIC[K, B]

feature -- Conversion (fixed per subclass)

	to_backend_value (fv: F): B deferred end
	to_frontend_value (bv: B): F deferred end

feature -- Factories

	as_combinator: RESTLY_COMBINATOR_DIADIC[K, F, B]
		do
			Result := Current
		end

feature -- Creation

	make (a_frontend: RESTLY_VERBS_BASIC[K, F]; a_backend: RESTLY_VERBS_BASIC[K, B])
		do
			make_with_front (a_frontend)
			backend := a_backend
		end
end
