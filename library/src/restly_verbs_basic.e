note
	description: "[
	* {RESTLY_VERBS_BASIC} Immutable-by-default Store Protocol.
	Analogous to HTTP Head, Get, Put.
	item returns a deep_twin so callers cannot affect the store.
	To update a value use put(new_v, key).
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	RESTLY_VERBS_BASIC[K->HASHABLE,V]

inherit
	RESTLY_VERBS_BASIC_MUTABLE[K,V]

convert
	as_combinator : {RESTLY_COMBINATOR_DETACHABLE[K,V]}

feature -- Access

	item alias "[]" (k: K): V assign force
		deferred
	ensure then
		independent_but_eqivalent: Result /= mutable_item (k) implies deep_equal (Result, mutable_item (k))
	end

feature -- Conversion

	as_combinator : RESTLY_COMBINATOR_DETACHABLE[K,V]
		do
			create {RESTLY_COMBINATOR_FRONTEND[K,V]} Result.make_with_front (Current)
		end

end
