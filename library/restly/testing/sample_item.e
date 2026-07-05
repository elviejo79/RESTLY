note
	description: "Simple domain object for pipeline front tests."

class
	SAMPLE_ITEM

create
	make

feature {NONE} -- Initialization

	make (a_title: STRING)
			-- Initialize with `a_title`.
		do
			title := a_title
		end

feature -- Access

	title: STRING
			-- Item title.

feature -- Element Change

	set_title (a_title: STRING)
			-- Update `title`.
		do
			title := a_title
		end

end
