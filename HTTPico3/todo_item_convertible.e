class TODO_ITEM_CONVERTIBLE

inherit
	TODO_ITEM
	CONVERTIBLE_WITH_JSON_VALUE
	CONVERTIBLE_WITH_STRING_32
		undefine
			is_equal
		end

create
	make_empty,
	make_from_json_value,
	make_from_string_32

convert
	make_from_json_value ({JSON_VALUE}),
	make_from_string_32 ({STRING_32}),
	to_json_value: {JSON_VALUE},
	to_string_32: {STRING_32}

   
feature -- convertible_with json_value
	to_json_value: JSON_VALUE
		local
			obj: EJSON_JSON_OBJECT
		do
			create obj.make_with_capacity (5)
			obj.put_integer (id, "id")
			obj.put_string (title, "title")
			obj.put_boolean (completed, "completed")
			obj.put_integer (order, "order")
			obj.put_string (url.string, "url")
			Result := obj
		end

	make_from_json_value (jv: JSON_VALUE)
		do
			make_empty
			if attached {EJSON_JSON_OBJECT} jv as obj then
				if attached {JSON_STRING} obj.item ("title") as t then
					title := t.unescaped_string_32
				end
				if attached {JSON_BOOLEAN} obj.item ("completed") as c then
					completed := c.item
				end
				if attached {JSON_NUMBER} obj.item ("order") as o then
					order := o.integer_64_item.to_integer
				end
				if attached {JSON_NUMBER} obj.item ("id") as i then
					id := i.integer_64_item.to_integer
				end
			end
		end

	from_json_value (jv: JSON_VALUE): TODO_ITEM_CONVERTIBLE
			-- Function version that returns a new instance
		do
			create Result.make_from_json_value (jv)
		end

	new_from_json_value (jv: JSON_VALUE): like Current
			-- Static factory method
		do
			create Result.make_from_json_value (jv)
		end


feature -- convertible_with string_32
	to_string_32: STRING_32
		do
			Result := to_json_value.representation
		end
	make_from_string_32 (other: STRING_32)
		local
			parser: JSON_PARSER
		do
			create parser.make_with_string (other.to_string_8)
			parser.parse_content
			check parser.is_valid and then attached parser.parsed_json_value as jv then
				make_from_json_value (jv)
			end
		end

	from_string_32 (other: STRING_32): TODO_ITEM_CONVERTIBLE
			-- Function version that returns a new instance
		do
			create Result.make_from_string_32 (other)
		end

end
