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
			default_create, is_equal, copy
		end

create
	default_create

feature -- Initialization

	default_create
			-- Empty row (ABEL deserialization and the reflective
			-- converter both need a default creation).
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

feature {RESTLY_TABLE_ORIGIN} -- Element Change

	set_id (a_id: INTEGER)
			-- <Precursor>
		do
			id := a_id
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
