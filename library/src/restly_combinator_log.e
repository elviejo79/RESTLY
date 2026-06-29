note
	description: "[
	{RESTLY_COMBINATOR_LOG}
	A transparent combinator that records every operation (with a monotonic tick,
	operation name, and value) to an internal list without altering chain behavior.
	Delegates all reads/writes to the backend unchanged.
	]"

class
	RESTLY_COMBINATOR_LOG[K->HASHABLE, V]

inherit
	RESTLY_COMBINATOR_DIADIC[K, V, V]
		redefine
			make,
			mutable_item, has_key, new_cursor, at_key,
			extend, remove, wipe_out, count
		end

create
	make, fronted_by

feature -- Creation

	fronted_by (a_frontend: RESTLY_VERBS_BASIC[K, V])
		do
			make (a_frontend, a_frontend)
		end

	make (a_frontend: RESTLY_VERBS_BASIC[K, V]; a_backend: RESTLY_VERBS_BASIC[K, V])
		do
			Precursor (a_frontend, a_backend)
			create entries.make (8)
		end

feature -- Conversion

	to_backend_value (fv: V): V do Result := fv end
	to_frontend_value (bv: V): V do Result := bv end

feature -- Factories

	new_instance (a_frontend: RESTLY_VERBS_BASIC[K, V]; a_backend: RESTLY_VERBS_BASIC[K, V]): like Current
		do
			create Result.make (a_frontend, a_backend)
		end

	backed_by alias "<|" (a_backend: RESTLY_VERBS_BASIC[K, V]): like Current
			-- Mutate self when in placeholder state so callers keep a valid reference
			-- to the embedded log node after chain building.
		do
			if backend = frontend then
				backend := a_backend
				Result := Current
			elseif attached {RESTLY_COMBINATOR_DETACHABLE[K, V]} backend as any_comb then
				Result := new_instance (frontend, any_comb.backed_by (a_backend))
			else
				(create {DEVELOPER_EXCEPTION}).raise
				Result := new_instance (frontend, new_instance (backend, a_backend))
			end
		end

	with_front alias "|>" (a_front: RESTLY_VERBS_BASIC[K, V]): like Current
		do
			Result := new_instance (a_front, backend)
		end

feature -- Log

	entries: ARRAYED_LIST[TUPLE[tick: INTEGER; op: STRING; value: detachable ANY]]

feature -- Access

	item alias "[]" (k: K): V
		do
			Result := backend.item (k)
			log_op ("item", Result)
		end

	mutable_item (k: K): V
		do
			Result := backend.mutable_item (k)
			log_op ("mutable_item", Result)
		end

feature -- Search

	has_key (k: K): BOOLEAN
		do
			Result := backend.has_key (k)
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

feature -- Extension

	extend (v: V; k: K)
		do
			backend.extend (v, k)
			log_op ("extend", v)
		end

feature -- Removal

	remove (k: K)
		do
			backend.remove (k)
			log_op ("remove", Void)
		end

	wipe_out
		do
			backend.wipe_out
			log_op ("wipe_out", Void)
		end

feature -- Measurement

	count: INTEGER
		do
			Result := backend.count
		end

feature {NONE} -- Implementation

	tick: INTEGER

	log_op (op: STRING; value: detachable ANY)
		do
			tick := tick + 1
			entries.extend ([tick, op, value])
		end

end
