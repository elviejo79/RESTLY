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
		require
			same_request_means_same_value: True -- TODO(owner): contract
		do
			if not extend_requests.has_key (a_request_id) then
				extend (a_v, fresh_key)
				extend_requests.extend (fresh_key, a_request_id)
			end
		ensure
			request_recorded: extend_requests.has_key (a_request_id)
			key_present: has_key (extend_requests [a_request_id])
			value_stored: item (extend_requests [a_request_id]) ~ a_v
		end

feature -- Access

	extend_requests: V_HASH_TABLE [HASHABLE, K]
			-- Maps request_id -> generated key.
		attribute
			create Result.with_object_equality
		end

feature -- Key minting

	fresh_key: K
			-- Next unused key.
		deferred
		end

end
