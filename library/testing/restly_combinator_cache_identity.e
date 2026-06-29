note
	description: "Concrete cache with identity conversions, for use in tests."

class
	RESTLY_COMBINATOR_CACHE_IDENTITY[K->HASHABLE, V]

inherit
	RESTLY_COMBINATOR_CACHE[K, V, V]
		redefine
			mutable_item, new_cursor, at_key
		end

create
	make, fronted_by

feature -- Creation

	fronted_by (a_frontend: RESTLY_VERBS_BASIC[K, V])
			-- Initialize with a_frontend as both frontend and backend (placeholder until backed_by is called).
		do
			make (a_frontend, a_frontend)
		end

feature -- Factories

	new_instance (a_frontend: RESTLY_VERBS_BASIC[K, V]; a_backend: RESTLY_VERBS_BASIC[K, V]): like Current
		do
			create Result.make (a_frontend, a_backend)
		end

	backed_by alias "<|" (a_backend: RESTLY_VERBS_BASIC[K, V]): like Current
		do
			if backend = frontend then
				Result := new_instance (frontend, a_backend)
			elseif attached {RESTLY_COMBINATOR_DETACHABLE[K, V]} backend as any_comb then
				Result := new_instance (frontend, any_comb.backed_by (a_backend))
			else
				Result := new_instance (frontend, new_instance (backend, a_backend))
			end
		end

	with_front alias "|>" (a_front: RESTLY_VERBS_BASIC[K, V]): like Current
		do
			Result := new_instance (a_front, backend)
		end

feature -- Conversion

	to_backend_value (fv: V): V do Result := fv end
	to_frontend_value (bv: V): V do Result := bv end

feature -- Access

	mutable_item (k: K): V
		do
			if frontend.has_key (k) then
				Result := frontend.mutable_item (k)
			else
				Result := backend.mutable_item (k)
			end
		end

feature -- Iteration

	new_cursor: like backend.new_cursor
		do
			Result := backend.new_cursor
		end

	at_key (k: K): like backend.at_key
		do
			Result := backend.at_key (k)
		end

end
