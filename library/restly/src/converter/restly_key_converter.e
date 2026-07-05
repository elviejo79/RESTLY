note
	description: "[
		Key conversion between pipeline stages.
		Deliberately a distinct type from RESTLY_CONVERTER:
		a pipeline that says KEY_CONVERTER reads as
		"this converts KEYS, not values".
	]"

deferred class
	RESTLY_KEY_CONVERTER [K_REPRESENTATION, K_STORE]

inherit
	RESTLY_CONVERTER [K_REPRESENTATION, K_STORE]

end
