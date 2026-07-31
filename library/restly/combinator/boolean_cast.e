note
	description: "[
		Boolean-cast combinator: fronts the wired `back` store with
		call/return semantics — every verb executes and reports its
		outcome as a BOOLEAN instead of enforcing the store's
		preconditions on the caller. A missing key or a failure
		inside `back` comes back as False, never as an exception.
		Wire with:  (create {BOOLEAN_CAST [K, V]}) <| a_store
	]"
	author: "agarciafdz@gmail.com"

class
	BOOLEAN_CAST [K -> HASHABLE, V]

inherit
	BOOLEAN_INTERFACE [K, V]

	RESTLY_UNARY_COMBINATOR [K, V]

create
	default_create,
	make_with_back

feature -- Queries

	has_key (k: K): BOOLEAN
			-- HEAD: is a resource with key `k` present?
		do
			Result := back.has_key (k)
		ensure then
			definition: Result = back.has_key (k)
		end

	item alias "[]" (k: K): BOOLEAN
			-- GET as a report: is the resource addressed by `k` there?
		do
			Result := back.has_key (k)
		end

feature -- Commands as reports

	extend (v: V; k: K): BOOLEAN
			-- POST: create new resource `k` carrying `v`.
			-- True on success; False if `k` already exists or `back` fails.
		do
			Result := not back.has_key (k) and then attempt (agent back.extend (v, k))
		end

	force (v: V; k: K): BOOLEAN
			-- PUT (upsert): store `v` at `k` whether or not it exists.
			-- True on success; False if `back` fails.
		do
			Result := attempt (agent back.force (v, k))
		end

	put (v: V; k: K): BOOLEAN
			-- PUT with exists: update existing resource `k` with `v`.
			-- True on success; False if `k` is absent or `back` fails.
		do
			Result := back.has_key (k) and then attempt (agent back.put (v, k))
		end

	remove (k: K): BOOLEAN
			-- DELETE: remove resource `k`.
			-- True on success; False if `k` is absent or `back` fails.
		do
			Result := back.has_key (k) and then attempt (agent back.remove (k))
		end

	merge (a_patch: JSON_OBJECT; a_k: K): BOOLEAN
			-- PATCH: update resource `a_k` with the parts named in `a_patch`.
			-- True on success; False if `a_k` is absent or `back` fails.
		do
			Result := back.has_key (a_k) and then attempt (agent back.merge (a_patch, a_k))
		end

feature {NONE} -- Implementation

	attempt (a_action: PROCEDURE): BOOLEAN
			-- Call `a_action`; True if it completed, False if it failed.
		local
			l_failed: BOOLEAN
		do
			if not l_failed then
				a_action.apply
				Result := True
			end
		rescue
			-- A rescue that falls off the end re-raises; setting the
			-- flag and retrying is how the failure becomes a False.
			l_failed := True
			retry
		end

end
