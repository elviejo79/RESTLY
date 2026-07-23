note
	description: "[
		Mixin: server-minted key creation with idempotency.
		Inherit alongside RESTLY_PROTOCOL [K, V].
	]"

deferred class
	RESTLY_POSTABLE [K -> HASHABLE, V]

inherit
	RESTLY_PROTOCOL [K, V]

feature -- Extension

	extend_new (a_v: V; a_request_id: HASHABLE)
			-- Create a new entry with a server-minted key.
			-- Idempotent: a duplicate `a_request_id` with the same value is a no-op.
			-- Default: mint via `fresh_key`, then extend; backends
			-- where the key is born on insert (databases) redefine.
		require
			same_request_means_same_value: True -- TODO(owner): contract
		local
			l_key: K
		do
			if not extend_requests.has_key (a_request_id) then
				l_key := fresh_key (a_v)
				extend (a_v, l_key)
				extend_requests.extend (l_key, a_request_id)
			end
		ensure
			request_recorded: extend_requests.has_key (a_request_id)
			key_present: has_key (extend_requests [a_request_id])
			value_stored: item (extend_requests [a_request_id]) ~ a_v
		end

feature {NONE} -- Key minting

	fresh_key (a_v: V): K
			-- New unused key for `a_v`; the store's minting policy.
			-- TODO(owner): contract (fresh: not has_key (Result))
		deferred
		end

feature -- Access

	extend_requests: V_HASH_TABLE [HASHABLE, K]
			-- Maps request_id -> generated key.
		attribute
			create Result.with_object_equality
		end

end
