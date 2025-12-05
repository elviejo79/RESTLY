note
	description: "[
		{INTERMEDIARY}.
		A deferred base class for creating intermediary implementations
		of HTTPICO_VERBS that coordinate between a source and destination.

		Provides common infrastructure for patterns like caching, logging,
		transformation, etc. where operations involve both a front-facing
		source and a backing destination.
	]"
	author: "Alejandro Garcia"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	INTERMEDIARY [R -> attached ANY, S -> attached ANY]

inherit
	HTTPICO_VERBS [R]

feature {NONE} -- Initialization

	make (a_front: HTTPICO_VERBS[R]; a_back: HTTPICO_VERBS[S])
			-- Initialize intermediary with source and destination
		do
			frontend := a_front
			backend := a_back
		ensure
			frontend_set: frontend = a_front
			backend_set: backend = a_back
		end

feature -- Access

	frontend: HTTPICO_VERBS[R]
			-- The front-facing storage (e.g., cache, local copy)

	backend: HTTPICO_VERBS[S]
			-- The backing storage (e.g., remote API, database)

end
