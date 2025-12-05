note
	description: "[
		{INTERMEDIARY_CONVERTIBLE}.
		A deferred intermediary implementation that supports conversion between
		different types R and S using the CONVERTIBLE_TO interface.

		This allows intermediaries to work with incompatible types where R can
		be converted to S via the to_s feature.
	]"
	author: "Alejandro Garcia"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	INTERMEDIARY_CONVERTIBLE [R -> CONVERTIBLE_TO[S], S -> attached ANY]

inherit
	INTERMEDIARY [R, S]

end
