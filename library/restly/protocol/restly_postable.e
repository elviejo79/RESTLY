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
			-- Minting is the implementor's private affair (a database
			-- mints on insert; an in-memory store probes for a gap).
		require
			same_request_means_same_value: True -- TODO(owner): contract
		deferred
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

end
