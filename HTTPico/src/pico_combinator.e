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
	PICO_COMBINATOR [R -> attached ANY, S -> attached ANY]

inherit
	PICO_REQUEST_METHODS [R]

feature {NONE} -- Initialization

	make (a_front: PICO_REQUEST_METHODS [R]; a_back: PICO_REQUEST_METHODS [S])
			-- Initialize intermediary with source and destination
		do
			frontend := a_front
			backend := a_back
		ensure
			frontend_set: frontend = a_front
			backend_set: backend = a_back
		end

feature -- Access

	frontend: PICO_REQUEST_METHODS [R]
			-- The front-facing storage (e.g., cache, local copy)

	backend: PICO_REQUEST_METHODS [S]
			-- The backing storage (e.g., remote API, database)

end
