note
	description: "[
		Flat row for RESTLY_TABLE tests: integer fields only, so
		default field-by-field equality holds across a database
		round trip.  Table convention: sample_row (id, amount).
	]"

class
	SAMPLE_ROW

create
	make

feature -- Initialization

	make (a_amount: INTEGER)
			-- Row worth `a_amount`.
		do
			amount := a_amount
		end

feature -- Access

	id: INTEGER
			-- Managed primary key; ABEL writes it back on insert.

	amount: INTEGER
			-- Payload.

feature -- Element Change

	set_amount (a_amount: INTEGER)
			-- Set `amount` to `a_amount`.
		do
			amount := a_amount
		end

end
