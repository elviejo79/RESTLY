note
	description: "[
		Mixin: QUERY (RFC 10008) protocol — safe, idempotent predicate reads.
		Q is the query representation; execution is the store's business.
	]"

deferred class
	RESTLY_SEARCHABLE [Q, K -> HASHABLE, V]

feature -- REST verbs

	search (a_query: Q): TABLE_ITERATION_CURSOR [V, K]
			-- All entries matching `a_query` (safe, idempotent).
		require
			error_400_bad_request: True
					-- TODO(owner): contract
					-- suggested: a_query is well-formed per the store's query language
		deferred
		end

end
