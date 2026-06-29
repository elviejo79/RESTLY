note
	description: "[
	The simplest combinator possible just forward the request to backend.
	{RESTLY_COMBINATOR_FRONTEND}.
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	RESTLY_COMBINATOR_FRONTEND[K->HASHABLE, V]

inherit
	RESTLY_COMBINATOR_DIADIC [K, V,V]
		redefine
			make_with_front,
			mutable_item, has_key, new_cursor, at_key,
			extend, remove, wipe_out, count
		end

      
create
	make,
	make_with_front
      
feature -- Creation

	make_with_front (a_frontend: RESTLY_VERBS_BASIC[K, V])
		do
			Precursor (a_frontend)
			backend := a_frontend
		end

feature -- Chaining

	backed_by alias "<|" (a_backend: RESTLY_VERBS_BASIC[K, V]): RESTLY_COMBINATOR_DETACHABLE[K, V]
		do
			backend := a_backend
			Result := Current
		end

feature -- Conversion

	to_backend_value (fv: V): V do Result := fv end
	to_frontend_value (bv: V): V do Result := bv end

feature -- Access

	item alias "[]" (k: K): V
		do
			Result := frontend.item (k)
		end

	mutable_item (k: K): V
		do
			Result := frontend.mutable_item (k)
		end

feature -- Search

	has_key (k: K): BOOLEAN
		do
			Result := frontend.has_key (k)
		end

feature -- Iteration

	new_cursor: like backend.new_cursor
		do
			Result := frontend.new_cursor
		end

	at_key (k: K): like backend.at_key
		do
			Result := frontend.at_key (k)
		end

feature -- Extension

	extend (v: V; k: K)
		do
			frontend.extend (v, k)
		end

feature -- Removal

	remove (k: K)
		do
			frontend.remove (k)
		end

	wipe_out
		do
			frontend.wipe_out
		end

feature -- Measurement

	count: INTEGER
		do
			Result := frontend.count
		end

end
