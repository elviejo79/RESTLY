note
	description: "[
Mixin for pipeline stages that delegate to a `back` stage
		speaking [SK, SV]. Says nothing about what the stage itself
		speaks up front: descendants declare their own front protocol
		(RESTLY_PROTOCOL, CALL_RETURN_PROTOCOL, ...).
	]"

deferred class
	RESTLY_COMPOSABLE [SK -> HASHABLE, SV]

feature -- Components

	back: RESTLY_PROTOCOL [SK, SV]
			-- Self-initialized to the null back end, so stages can be
			-- built bare (`create {STAGE}`) and wired afterwards with `<|`.
		attribute
			Result := {RESTLY_NULL [SK, SV]}.instance
		end

feature -- Creation

	make_with_back (a_back: like back)
		do
			back := a_back
		end

feature -- Composition

	backed_by alias "<|" (a_back: RESTLY_PROTOCOL [ANY, ANY]): like Current
			-- A fresh copy of Current wired to `a_back`; if my `back`
			-- is itself composable, `a_back` is appended to the chain
			-- instead of overwriting it.
			-- Loose [ANY, ANY] argument so left-associative chains
			-- (g <| c <| t) type-check; conformance is re-checked below.
			-- ponytail: twin-based copy; switch to a deferred `new`
			-- per stage if a stage ever carries state a shallow twin
			-- must not share.
		do
			Result := twin
			if attached {RESTLY_COMPOSABLE [HASHABLE, ANY]} back as l_chain then
				check chain_speaks_my_types: attached {RESTLY_PROTOCOL [SK, SV]} (l_chain <| a_back) as l_new then
					Result.make_with_back (l_new)
				end
			else
				check back_speaks_my_types: attached {RESTLY_PROTOCOL [SK, SV]} a_back as l_new then
					Result.make_with_back (l_new)
				end
			end
		end

end
