note
	description: "Minimum set of REST verb abstractions backed by a hash table."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	RESTLY_PROTOCOL [K -> HASHABLE, V]

inherit
	ANY
		undefine
			is_equal,
			copy,
			out,
			default_create
		end

feature -- REST verbs

	item alias "[]" (k: K): V assign force
			-- GET: value associated with `k`.
		require
			error_404_not_found: has_key (k)
		deferred
		end

	has_key (k: K): BOOLEAN
			-- HEAD: is a resource with key `k` present?
		deferred
		end

	extend (v: V; k: K)
			-- POST: create new resource with key `k`; must not already exist.
		require
			error_403_must_use_fresh_key: not has_key (k)
		deferred
		ensure
			error_500_didnt_actually_update: has_key(k) and then item(k) ~ v 
		end

	force (v: V; k: K)
			-- PUT: upsert resource; creates or replaces.
		deferred
		ensure
         error_500_didnt_actually_insert: has_key(k) and then item(k) ~ v 
		end

	put (v: V; k: K)
			-- PUT with exists: update existing resource; `k` must already exist.
		note
			modify: table
		require
			has_key: has_key (k)
		deferred
		ensure
         error_500_didnt_actually_update: item(k) ~ v
		end

	remove (k: K)
			-- DELETE: remove resource with key `k`.
		note
			modify: table
		require
			has_key: has_key (k)
		deferred
		ensure
			error_500_didnt_actually_delete: not has_key(k)
		end

end
