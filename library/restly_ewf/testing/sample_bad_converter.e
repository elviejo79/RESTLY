note
	description: "[
		Declares a mismatch for an attribute SAMPLE_RECORD does not
		have; `make` must raise at wiring time.
	]"

class
	SAMPLE_BAD_CONVERTER

inherit
	RESTLY_JSON_REFLECTIVE_CONVERTER [SAMPLE_RECORD]
		redefine
			correct_mismatches
		end

create
	make

feature {NONE} -- Mismatch declarations

	correct_mismatches
			-- <Precursor>
		do
			skip_field ("no_such_attribute")
		end

end
