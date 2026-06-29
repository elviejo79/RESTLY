note
	description: "[
	This is a combinator that doesn't have a backend.
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	RESTLY_COMBINATOR_DETACHABLE[K->HASHABLE, V]

inherit
	RESTLY_VERBS_BASIC [K, V]

feature {NONE} -- Implementation

	frontend: RESTLY_VERBS_BASIC[K, V]

feature -- Chaining

	backed_by alias "<|" (a_backend: RESTLY_VERBS_BASIC[K, V]): RESTLY_COMBINATOR_DETACHABLE[K, V]
		deferred
		end

feature -- Creation

	make (a_frontend: RESTLY_VERBS_BASIC[K, V])
		do
			v_table_default_create
			frontend := a_frontend
		end
end
