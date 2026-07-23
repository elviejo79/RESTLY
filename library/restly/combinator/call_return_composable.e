note
	description: "[
		Mixin for pipeline stages that delegate to a `back` stage
		speaking CALL_RETURN_PROTOCOL [I, O] — the layer in front of
		the gateway, where the transport request (headers included)
		still exists. Sibling of RESTLY_COMPOSABLE for the
		call/return side.
	]"

deferred class
	CALL_RETURN_COMPOSABLE [I, O]

feature -- Components

	back: CALL_RETURN_PROTOCOL [I, O]
			-- Self-initialized to the null handler, so stages can be
			-- built bare (`create {STAGE}`) and wired afterwards with `<|`.
		attribute
			Result := {CALL_RETURN_NULL [I, O]}.instance
		end

feature -- Creation

	make_with_back (a_back: like back)
		do
			back := a_back
		end

feature -- Composition

	backed_by alias "<|" (a_back: ANY): like Current
			-- A fresh copy of Current wired to `a_back`: a call/return
			-- stage becomes my `back`; a RESTLY_PROTOCOL stage is
			-- appended behind my `back`'s own chain, so mixed chains
			-- (auth <| gateway <| codec <| store) type-check
			-- left-associatively. ANY argument for the same reason
			-- RESTLY_COMPOSABLE's is loose; conformance is re-checked
			-- below.
		do
			Result := twin
			if attached {CALL_RETURN_PROTOCOL [I, O]} a_back as l_handler then
				Result.make_with_back (l_handler)
			else
				check back_chains: attached {RESTLY_COMPOSABLE [HASHABLE, ANY]} back as l_chain then
					check store_arg: attached {RESTLY_PROTOCOL [ANY, ANY]} a_back as l_store then
						check chained_handler: attached {CALL_RETURN_PROTOCOL [I, O]} (l_chain <| l_store) as l_new then
							Result.make_with_back (l_new)
						end
					end
				end
			end
		end

end
