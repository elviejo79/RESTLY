note
	description: "[
		Mixin: partial update of an existing entry.
		The patch is a PARTIAL VALUE of the same representation type.
		No RESTLY_MERGEABLE constraint on V.
		Inherit alongside RESTLY_PROTOCOL [K, V].
	]"

deferred class
	RESTLY_PATCHABLE [K -> HASHABLE, V]

inherit
	RESTLY_PROTOCOL [K, V]

feature -- Update

	merge (a_patch: V; a_k: K)
			-- Update item at `a_k` with parts named in `a_patch`;
			-- absent parts stay intact.
		require
			error_404_not_found: has_key (a_k)
		deferred
		ensure
			key_still_present: has_key (a_k)
		end

end
