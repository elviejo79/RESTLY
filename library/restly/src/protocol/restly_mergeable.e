note
	description: "[
		Contract for domain objects that accept partial updates.
		Kept available but UNUSED in v1: PATCH is a JSON-on-JSON merge
		at the pipeline front.
	]"

deferred class
	RESTLY_MERGEABLE

feature -- Update

	copy_from_tuple (a_patch: TUPLE)
			-- Apply partial update from labelled TUPLE.
			-- Void field means "absent from PATCH, leave unchanged".
		deferred
		end

end
