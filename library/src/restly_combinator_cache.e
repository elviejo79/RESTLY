note
	description: "[
	{RESTLY_COMBINATOR_CACHE}
	A caching combinator. frontend acts as the cache, backend is the source of truth.
	Reads check frontend first; only go to backend on a miss, then populate the cache.
	Writes update both frontend and backend.
	Subclasses must supply the two value conversion features.
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	RESTLY_COMBINATOR_CACHE[K->HASHABLE, FV, BV]

inherit
	RESTLY_COMBINATOR_DIADIC[K, FV, BV]
		redefine
			has_key, extend, remove, wipe_out, count
		end

feature -- conversion
	to_backend_value (fv: FV): BV deferred end
	to_frontend_value (bv: BV): FV deferred end

feature -- Access

	item alias "[]" (k: K): FV
		local
			fv: FV
		do
			if frontend.has_key (k) then
				Result := frontend.item (k)
			else
				fv := to_frontend_value (backend.item (k))
				frontend.extend (fv, k)
				Result := fv
			end
		end

feature -- Search

	has_key (k: K): BOOLEAN
		do
			Result := frontend.has_key (k) or else backend.has_key (k)
		end

feature -- Extension

	extend (fv: FV; k: K)
		do
			frontend.extend (fv, k)
			backend.extend (to_backend_value (fv), k)
		end

feature -- Removal

	remove (k: K)
		do
			if frontend.has_key (k) then
				frontend.remove (k)
			end
			backend.remove (k)
		end

	wipe_out
		do
			frontend.wipe_out
			backend.wipe_out
		end

feature -- Measurement

	count: INTEGER
		do
			Result := backend.count
		end

end
