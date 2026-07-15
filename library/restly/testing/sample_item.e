note
	description: "Simple domain object for pipeline front tests."

class
	SAMPLE_ITEM

inherit
	ANY
		redefine
			default_create
		end

create
	make,
	default_create

feature {NONE} -- Initialization

	make (a_title: STRING)
			-- Initialize with `a_title`.
		do
			title := a_title
		end

	default_create
			-- Item with empty title.
		do
			create title.make_empty
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
