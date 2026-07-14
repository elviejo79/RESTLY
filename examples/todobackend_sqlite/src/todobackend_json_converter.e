note
	description: "[
		Declares the JSON/TODO_ROW schema mismatches; matching
		fields (title) flow by reflection.
	]"

class
	TODOBACKEND_JSON_CONVERTER

inherit
	RESTLY_JSON_REFLECTIVE_CONVERTER [TODO_ROW]
		redefine
			correct_mismatches
		end

create
	make

feature {NONE} -- Mismatch declarations

	correct_mismatches
			-- <Precursor>
		do
			skip_field ("id")
					-- Identity travels in the URL, not the body.
			rename_field ("order_value", "order")
			convert_boolean_integer_field ("completed",
				agent (a_completed: BOOLEAN): INTEGER do if a_completed then Result := 1 end end,
				agent (a_completed: INTEGER): BOOLEAN do Result := a_completed /= 0 end)
					-- ABEL's relational connector cannot round-trip BOOLEAN.
		end

end
