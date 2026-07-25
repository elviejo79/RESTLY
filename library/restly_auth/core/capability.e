note
	description: "[
		Who you are plus what you may do: the keycard (Idea 1).
		A capability is its query set (Addendum 2026-07-24): the four
		queries are the protocol's verb vocabulary collapsed onto
		capability questions — readable (item, has_key, cursors),
		writable (force, put, extend, merge), removable (remove,
		wipe_out), creatable (extend_new).
		`is_valid` is structural only — never expiry (ground rule 4).
		Obligation on every implementation (ground rule 9):
		writable (k) implies readable (k); creatable implies writable
		and readable on keys minted for this capability's own
		principal. These quantify over all keys, so they are enforced
		by construction, not invariant.
	]"

deferred class
	CAPABILITY

feature -- Access

	subject: STRING
			-- Whom this capability speaks for.
		deferred
		end

	is_valid: BOOLEAN
			-- Structurally sound? (Never checks expiry — Idea 4.)
		deferred
		end

feature -- Queries (the protocol's verbs, collapsed)

	readable (a_key: HASHABLE): BOOLEAN
			-- May the resource at `a_key` be read?
		deferred
		end

	writable (a_key: HASHABLE): BOOLEAN
			-- May the resource at `a_key` be written?
		deferred
		end

	removable (a_key: HASHABLE): BOOLEAN
			-- May the resource at `a_key` be deleted?
		deferred
		end

	creatable: BOOLEAN
			-- May a fresh resource be minted? k-independent: the key
			-- does not exist yet.
		deferred
		end

end
