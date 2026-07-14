note
	description: "[
		Flat row for RESTLY_TABLE_ORIGIN tests: integer fields only, so
		default field-by-field equality holds across a database
		round trip.  Table convention: sample_row (id, amount).
	]"

class
	SAMPLE_ROW

inherit
	RESTLY_IDENTIFIABLE [INTEGER]

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
			-- <Precursor>

	amount: INTEGER
			-- Payload.

feature -- Element Change

	set_id (a_id: INTEGER)
			-- <Precursor>
		do
			id := a_id
		end

	set_amount (a_amount: INTEGER)
			-- Set `amount` to `a_amount`.
		do
			amount := a_amount
		end

end
