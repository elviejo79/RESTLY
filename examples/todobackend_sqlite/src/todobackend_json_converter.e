note
	description: "Converts between JSON_OBJECT and TODO_ROW."

class
	TODOBACKEND_JSON_CONVERTER

inherit
	RESTLY_CONVERTER [JSON_OBJECT, TODO_ROW]

feature -- Conversion

	to_store (a_representation: JSON_OBJECT): TODO_ROW
			-- Extract TODO_ROW fields from JSON; ignore "url" and "id".
		local
			l_title: STRING
			l_completed: INTEGER
			l_order: INTEGER
		do
			if attached {JSON_STRING} a_representation.item ("title") as l_json_title then
				l_title := l_json_title.unescaped_string_8
			else
				create l_title.make_empty
			end
			if attached {JSON_BOOLEAN} a_representation.item ("completed") as l_json_completed and then l_json_completed.item then
				l_completed := 1
			end
			if attached {JSON_NUMBER} a_representation.item ("order") as l_json_order then
				l_order := l_json_order.integer_64_item.to_integer_32
			end
			create Result.make (l_title, l_completed, l_order)
		end

	to_representation (a_store: TODO_ROW): JSON_OBJECT
			-- Build JSON_OBJECT from TODO_ROW fields.
		do
			create Result.make_with_capacity (4)
			Result.put_string (a_store.title, "title")
			Result.put_boolean (a_store.is_completed, "completed")
			Result.put_integer (a_store.order_value, "order")
		end

end
