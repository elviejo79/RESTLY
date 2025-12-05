note
	description: "[
		{INTERMEDIARY_HEIR}.
		A deferred intermediary implementation where R is a descendant of S.

		This constraint (R -> {S}) ensures that R conforms to S, meaning R
		is either S itself or inherits from S. This allows safe assignment
		from R to S without explicit conversion.
	]"
	author: "Alejandro Garcia"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	INTERMEDIARY_HEIR [R -> {S}, S -> attached ANY]

inherit
	INTERMEDIARY [R, S]

end
