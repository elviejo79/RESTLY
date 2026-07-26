note
	description: "[
		Minimum set of REST verb abstractions backed by a hash table.
		Strengthens RESTLY_UNSAFE_PROTOCOL with delivery guarantees:
		the mutating verbs promise (ensure then) that the table really
		changed. Stores speak this; fronts that cannot promise delivery
		stay at RESTLY_UNSAFE_PROTOCOL.
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	RESTLY_PROTOCOL [K, V]

inherit
	RESTLY_UNSAFE_PROTOCOL [K, V]
		redefine
			force
		end

feature -- REST verbs

	extend (v: V; k: K)
			-- <Precursor>
		deferred
		ensure then
			error_500_didnt_actually_update: has_key(k) and then item(k) ~ v
		end

	force (v: V; k: K)
			-- <Precursor>
		do
			Precursor (v, k)
		ensure then
			error_500_didnt_actually_insert: has_key(k) and then item(k) ~ v
		end

	put (v: V; k: K)
			-- <Precursor>
		deferred
		ensure then
			error_500_didnt_actually_update: item(k) ~ v
		end

	remove (k: K)
			-- <Precursor>
		deferred
		ensure then
			error_500_didnt_actually_delete: not has_key(k)
		end

end
