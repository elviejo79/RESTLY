note
	description: "[
		The front desk (Idea 1): an asymmetric translation stage at the
		trust boundary mapping a raw credential to a typed capability,
		or refusing (401). `authenticated` is a pure function of its
		arguments — the time is the request-entry snapshot, threaded
		explicitly (ground rule 3); never a `once` (ground rule 7).
	]"

deferred class
	PRINCIPAL_CODEC [C]

feature -- Status report

	authenticated (a_raw: RAW_CREDENTIAL; a_time: DATE_TIME): BOOLEAN
			-- Does `a_raw` prove an identity, judged at `a_time`?
		deferred
		end

feature -- Access

	mint (a_raw: RAW_CREDENTIAL; a_time: DATE_TIME): C
			-- The capability `a_raw` proves.
		require
			established: authenticated (a_raw, a_time)
		deferred
		end

end
