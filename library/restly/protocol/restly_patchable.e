note
	description: "[
		Mixin: partial update of an existing entry.
		The patch is a JSON_OBJECT because a partial update is by
		definition incomplete — a typed V cannot represent "only
		these fields changed." JSON_OBJECT's named properties are
		the natural partial-data container: presence = intent to
		change, absence = leave alone.
		Default implementation: read current V, convert to JSON via
		the convert clause (to_json), merge patch fields, convert
		back (make_from_json), put. Descendants may override for
		optimized merge (e.g. SQL UPDATE SET on individual columns).
		Inherit alongside RESTLY_PROTOCOL [K, V].
	]"

deferred class
	RESTLY_PATCHABLE [K -> HASHABLE, V]

inherit
	RESTLY_PROTOCOL [K, V]

feature -- Update

	merge (a_patch: JSON_OBJECT; a_k: K)
			-- Update item at `a_k` with parts named in `a_patch`;
			-- absent parts stay intact.
		require
			error_404_not_found: has_key (a_k)
		local
			l_current: JSON_OBJECT
			l_merged: V
		do
			check current_converts_to_json: attached {JSON_OBJECT} item (a_k) as l_json then
				l_current := l_json.twin
			end
			across a_patch.current_keys as ic loop
				l_current.replace (a_patch [ic], ic)
			end
			check merged_converts_back: attached {V} l_current as l_v then
				l_merged := l_v
			end
			put (l_merged, a_k)
		ensure
			key_still_present: has_key (a_k)
		end

end
