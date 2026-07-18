note
	description: "[
		Declares the JSON/TODO_ROW schema mismatches; matching
		fields (title) flow by reflection.
	]"

class
	TODOBACKEND_CONVERTER_JSON_OBJECT_TODO_ROW

inherit
	RESTLY_JSON_REFLECTIVE_CONVERTER [TODO_ROW]
		redefine
			correct_mismatches
		end

create
	make

feature {NONE} -- Initialization

	make (a_base_url: STRING)
			-- Converter minting element urls under `a_base_url`.
		do
			base_url := a_base_url
			default_create
		end

feature -- Access

	base_url: STRING
			-- Collection url; element url = `base_url` + "/" + id.

feature {NONE} -- Mismatch declarations

	correct_mismatches
			-- <Precursor>
		do
			rename_field ("id", "url")
			convert_integer_string_field ("id",
				agent (a_url: STRING): INTEGER do end,
				agent (a_id: INTEGER): STRING do Result := base_url + "/" + a_id.out end)
					-- Identity travels in the representation as the element
					-- url; incoming urls are ignored — the table mints ids.
			rename_field ("order_value", "order")
			convert_boolean_integer_field ("completed",
				agent (a_completed: BOOLEAN): INTEGER do if a_completed then Result := 1 end end,
				agent (a_completed: INTEGER): BOOLEAN do Result := a_completed /= 0 end)
					-- ABEL's relational connector cannot round-trip BOOLEAN.
		end

end
