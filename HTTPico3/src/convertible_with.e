deferred class CONVERTIBLE_WITH [G]
-- note in the make claus of the heirs from_other must be part of the creation procedures.

convert
	make_from_other ({G}),
	to_other: {G}

feature {NONE} -- initialization
	make_from_other (other: G)
		deferred
		end

feature -- converter
	to_other: G
		deferred
		end

end
