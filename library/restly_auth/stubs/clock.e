note
	description: "[
		Time source. The gateway snapshots `now` once per request and
		threads the value; no interior code reads a clock (Idea 4).
	]"

deferred class
	CLOCK

feature -- Access

	now: DATE_TIME
			-- The current moment, UTC.
		deferred
		end

end
