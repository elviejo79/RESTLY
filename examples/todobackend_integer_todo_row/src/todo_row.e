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
	default_create,
	make_from_json

convert
	make_from_json ({JSON_OBJECT}),
	to_json: {JSON_OBJECT}

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

feature {TABLE_INTEGER_TODO_ROW} -- Element Change
	-- ponytail: exported to the minting store; widen to RESTLY_TABLE_ORIGIN when it exists.

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

feature -- Conversion

	make_from_json (a_j: JSON_OBJECT)
			-- Row built from wire representation `a_j`.
		require
			title_is_string: attached {JSON_STRING} a_j.item ("title")
			id_is_integer: a_j.has_key ("id") implies
				(attached {JSON_NUMBER} a_j.item ("id") as l_n and then l_n.is_integer_32)
			completed_is_boolean: a_j.has_key ("completed") implies
				attached {JSON_BOOLEAN} a_j.item ("completed")
			order_is_integer: a_j.has_key ("order") implies
				(attached {JSON_NUMBER} a_j.item ("order") as l_n and then l_n.is_integer_32)
		do
			default_create
			check title_guaranteed_by_precondition: attached {JSON_STRING} a_j.item ("title") as l_title then
				title := l_title.unescaped_string_8
			end
			if attached {JSON_NUMBER} a_j.item ("id") as l_id then
				id := l_id.integer_32_item
			end
			if attached {JSON_BOOLEAN} a_j.item ("completed") as l_completed and then l_completed.item then
				completed := 1
			end
			if attached {JSON_NUMBER} a_j.item ("order") as l_order then
				order_value := l_order.integer_32_item
			end
		end

	to_json: JSON_OBJECT
			-- Wire representation of Current.
		do
			create Result.make
			Result.put (create {JSON_NUMBER}.make_integer (id), "id")
			-- host/port must match {TODOBACKEND_SERVER}
			Result.put (create {JSON_STRING}.make_from_string ("http://localhost:8080/todos/" + id.out), "url")
			Result.put (create {JSON_STRING}.make_from_string (title), "title")
			Result.put (create {JSON_BOOLEAN}.make (completed = 1), "completed")
			Result.put (create {JSON_NUMBER}.make_integer (order_value), "order")
		end

end
