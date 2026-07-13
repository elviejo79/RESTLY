note
	description: "[
		Domain object stored in SQLite via ABEL. Table: todo_row.
		`completed` is INTEGER (0/1) because ABEL's relational
		connector does not round-trip BOOLEAN through SQLite.
	]"

class
	TODO_ROW

inherit
	RESTLY_IDENTIFIABLE [INTEGER]
		redefine
			is_equal, copy
		end

create
	make, make_default

feature -- Initialization

	make (a_title: STRING; a_completed: INTEGER; a_order_value: INTEGER)
			-- Row with all fields.
		do
			title := a_title
			completed := a_completed
			order_value := a_order_value
		end

	make_default
			-- Empty row (ABEL deserialization needs a default creation).
		do
			create title.make_empty
		end

feature -- Access

	id: INTEGER
			-- <Precursor>

	title: STRING
			-- Todo title.

	completed: INTEGER
			-- 1 = completed, 0 = not completed.

	order_value: INTEGER
			-- Sort order.

	is_completed: BOOLEAN
			-- Is this todo completed?
		do
			Result := completed /= 0
		end

feature {RESTLY_TABLE} -- Element Change

	set_id (a_id: INTEGER)
			-- <Precursor>
		do
			id := a_id
		end

feature -- Element Change

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

	set_order_value (a_order_value: INTEGER)
			-- Set `order_value` to `a_order_value`.
		do
			order_value := a_order_value
		end

feature -- Comparison

	is_equal (other: like Current): BOOLEAN
			-- <Precursor>
			-- Value equality: title by content, not reference.
		do
			Result := id = other.id
				and then title.same_string (other.title)
				and then completed = other.completed
				and then order_value = other.order_value
		end

feature -- Duplication

	copy (other: like Current)
			-- <Precursor>
		do
			title := other.title.twin
			completed := other.completed
			order_value := other.order_value
		end

end
