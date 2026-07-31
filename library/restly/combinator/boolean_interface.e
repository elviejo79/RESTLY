note
	description: "Common interface for stores whose verbs report BOOLEAN outcomes."
	author: "agarciafdz@gmail.com"

deferred class
	BOOLEAN_INTERFACE [K -> HASHABLE, V]

feature -- Queries

	has_key (k: K): BOOLEAN
			-- Is a resource with key `k` present?
		deferred
		end

	item alias "[]" (k: K): BOOLEAN
			-- Report for the resource addressed by `k`.
		deferred
		end

feature -- Commands as reports

	extend (v: V; k: K): BOOLEAN
			-- POST: create new resource `k` carrying `v`.
		deferred
		end

	force (v: V; k: K): BOOLEAN
			-- PUT (upsert): store `v` at `k`.
		deferred
		end

	put (v: V; k: K): BOOLEAN
			-- PUT with exists: update existing resource `k` with `v`.
		deferred
		end

	remove (k: K): BOOLEAN
			-- DELETE: remove resource `k`.
		deferred
		end

	merge (a_patch: JSON_OBJECT; a_k: K): BOOLEAN
			-- PATCH: update resource `a_k` with parts named in `a_patch`.
		deferred
		end

end
