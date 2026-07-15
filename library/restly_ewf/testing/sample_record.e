note
	description: "[
		Store fixture for reflective converter tests: one attribute
		per mismatch kind (skip, rename, type change) plus a natural
		match.
	]"

class
	SAMPLE_RECORD

inherit
	ANY
		redefine
			default_create
		end

create
	default_create

feature {NONE} -- Initialization

	default_create
			-- Record with empty title and zero fields.
		do
			create title.make_empty
		end

feature -- Access

	id: INTEGER
			-- Store-only identity (skipped in JSON).

	title: STRING
			-- Natural match.

	completed: INTEGER
			-- Boolean in JSON, integer here.

	order_value: INTEGER
			-- Travels in JSON as "order".

feature -- Element Change

	set_id (a_id: INTEGER)
			-- Set `id` to `a_id`.
		do
			id := a_id
		end

	set_title (a_title: STRING)
			-- Set `title` to `a_title`.
		do
			title := a_title
		end

	set_completed (a_completed: INTEGER)
			-- Set `completed` to `a_completed`.
		do
			completed := a_completed
		end

	set_order_value (a_order: INTEGER)
			-- Set `order_value` to `a_order`.
		do
			order_value := a_order
		end

end
