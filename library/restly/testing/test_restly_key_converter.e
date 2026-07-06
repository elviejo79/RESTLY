note
	description: "Tests for RESTLY_KEY_CONVERTER via SAMPLE_KEY_CONVERTER."

class
	TEST_RESTLY_KEY_CONVERTER

inherit
	EQA_TEST_SET

feature {NONE} -- Fixtures

	converter: SAMPLE_KEY_CONVERTER
		attribute create Result end

feature -- Tests

	test_round_trip_string_to_integer_to_string
			-- "42" -> 42 -> "42".
		local
			l_store: INTEGER
			l_repr: STRING
		do
			l_store := converter.to_store ("42")
			assert ("to_store correct", l_store = 42)
			l_repr := converter.to_representation (l_store)
			assert ("round trip", l_repr ~ "42")
		end

	test_round_trip_various_values
			-- Multiple values round-trip correctly.
		do
			assert ("1 round trips", converter.to_representation (converter.to_store ("1")) ~ "1")
			assert ("100 round trips", converter.to_representation (converter.to_store ("100")) ~ "100")
			assert ("0 round trips", converter.to_representation (converter.to_store ("0")) ~ "0")
		end

end
