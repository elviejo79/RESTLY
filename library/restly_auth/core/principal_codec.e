note
	description: "[
		The front desk (Idea 1): an asymmetric translation stage at the
		trust boundary mapping a bearer token to a typed capability,
		or refusing (401). `authenticated` is a pure function of its
		arguments — the time is the request-entry snapshot, threaded
		explicitly (ground rule 3); never a `once` (ground rule 7).
	]"

deferred class
	PRINCIPAL_CODEC [C]

feature -- Status report

	authenticated (a_token: READABLE_STRING_8; a_time: DATE_TIME): BOOLEAN
			-- Does `a_token` prove an identity, judged at `a_time`?
			-- Empty string = absent credential.
		deferred
		end

feature -- Access

	mint (a_token: READABLE_STRING_8; a_time: DATE_TIME): C
			-- The capability `a_token` proves.
		require
			established: authenticated (a_token, a_time)
		deferred
		end

end
