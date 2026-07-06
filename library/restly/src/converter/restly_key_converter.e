note
	description: "[
		Key conversion between pipeline stages.
		Deliberately a distinct type from RESTLY_CONVERTER:
		a pipeline that says KEY_CONVERTER reads as
		"this converts KEYS, not values".
		Carries a strictly stronger contract than value
		converters: keys must round-trip EXACTLY in both
		directions (a bijection), or router lookups break.
	]"

deferred class
	RESTLY_KEY_CONVERTER [K_REPRESENTATION, K_STORE]

inherit
	RESTLY_CONVERTER [K_REPRESENTATION, K_STORE]

feature -- Conversion

	to_store (a_representation: K_REPRESENTATION): K_STORE
			-- <Precursor>
			-- No canonicalization allowed for keys.
		deferred
		ensure then
			exact_key_round_trip: True -- TODO(owner): contract
		end

	to_representation (a_store: K_STORE): K_REPRESENTATION
			-- <Precursor>
			-- No representation-side defaults for keys.
		deferred
		ensure then
			exact_store_round_trip: True -- TODO(owner): contract
		end

end
