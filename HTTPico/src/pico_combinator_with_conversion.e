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
	PICO_COMBINATOR_WITH_CONVERSION [R -> attached ANY, S -> attached ANY]

inherit
   PICO_COMBINATOR[R,S]

feature {NONE} --

conv: PICO_CONVERTER[R,S]

end
