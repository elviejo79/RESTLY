note
	description: "[
		Declares all three mismatch kinds for SAMPLE_RECORD; title
		flows by reflection.
	]"

class
	SAMPLE_RECORD_CONVERTER

inherit
	RESTLY_JSON_REFLECTIVE_CONVERTER [SAMPLE_RECORD]
		redefine
			correct_mismatches
		end

create
	default_create

feature {NONE} -- Mismatch declarations

	correct_mismatches
			-- <Precursor>
		do
			skip_field ("id")
			rename_field ("order_value", "order")
			convert_boolean_integer_field ("completed",
				agent (a_completed: BOOLEAN): INTEGER do if a_completed then Result := 1 end end,
				agent (a_completed: INTEGER): BOOLEAN do Result := a_completed /= 0 end)
		end

end
