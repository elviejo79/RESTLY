note
	description: "Settable clock for tests: time passes only when a test says so."

class
	TEST_CLOCK

inherit
	CLOCK

create
	make

feature {NONE} -- Initialization

	make
		do
			create now.make_now_utc
		end

feature -- Access

	now: DATE_TIME assign set_now

feature -- Element change

	set_now (a_time: DATE_TIME)
		do
			now := a_time
		end

end
