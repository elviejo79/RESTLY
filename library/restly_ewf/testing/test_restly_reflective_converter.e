note
	description: "[
		Tests for RESTLY_REFLECTIVE_CONVERTER: natural flow by
		reflection, declared mismatches (skip, rename, type change),
		and the wiring-time schema check.
	]"

class
	TEST_RESTLY_REFLECTIVE_CONVERTER

inherit
	EQA_TEST_SET

feature -- Tests

	test_to_store_fills_matched_renamed_and_converted
		local
			l_record: SAMPLE_RECORD
		do
			l_record := converter.to_store (new_json ("buy milk", True, 7))
			assert ("title matched", l_record.title.same_string ("buy milk"))
			assert ("completed converted", l_record.completed = 1)
			assert ("order renamed", l_record.order_value = 7)
			assert ("id keeps default", l_record.id = 0)
		end

	test_to_store_absent_fields_keep_defaults
		local
			l_record: SAMPLE_RECORD
			l_json: JSON_OBJECT
		do
			create l_json.make_with_capacity (1)
			l_json.put_string ("only title", "title")
			l_record := converter.to_store (l_json)
			assert ("title set", l_record.title.same_string ("only title"))
			assert ("completed default", l_record.completed = 0)
			assert ("order default", l_record.order_value = 0)
		end

	test_to_representation_skips_renames_and_converts
		local
			l_record: SAMPLE_RECORD
			l_json: JSON_OBJECT
		do
			create l_record.make_default
			l_record.set_id (42)
			l_record.set_title ("walk dog")
			l_record.set_completed (1)
			l_record.set_order_value (3)
			l_json := converter.to_representation (l_record)
			assert ("id skipped", not l_json.has_key ("id"))
			assert ("attribute name does not travel", not l_json.has_key ("order_value"))
			check attached {JSON_STRING} l_json.item ("title") as l_title then
				assert ("title travels", l_title.unescaped_string_8.same_string ("walk dog"))
			end
			check attached {JSON_BOOLEAN} l_json.item ("completed") as l_completed then
				assert ("completed is boolean true", l_completed.item)
			end
			check attached {JSON_NUMBER} l_json.item ("order") as l_order then
				assert ("order renamed", l_order.integer_64_item = 3)
			end
		end

	test_base_converter_with_no_mismatches
		local
			l_converter: RESTLY_JSON_REFLECTIVE_CONVERTER [SAMPLE_ITEM]
			l_json: JSON_OBJECT
		do
			create l_converter.make (agent: SAMPLE_ITEM do create Result.make ("") end)
			create l_json.make_with_capacity (1)
			l_json.put_string ("all natural", "title")
			assert ("title round trip",
				l_converter.to_store (l_json).title.same_string ("all natural"))
		end

	test_schema_error_on_misdeclared_attribute
		local
			l_converter: detachable SAMPLE_BAD_CONVERTER
			l_raised: BOOLEAN
		do
			if not l_raised then
				create l_converter.make (agent: SAMPLE_RECORD do create Result.make_default end)
				assert ("schema error raised", False)
			end
			assert ("raised at wiring time", l_raised)
		rescue
			l_raised := True
			retry
		end

feature {NONE} -- Fixtures

	converter: SAMPLE_RECORD_CONVERTER
		attribute create Result.make (agent: SAMPLE_RECORD do create Result.make_default end) end

	new_json (a_title: STRING; a_completed: BOOLEAN; a_order: INTEGER): JSON_OBJECT
			-- JSON body with the three travelling fields.
		do
			create Result.make_with_capacity (3)
			Result.put_string (a_title, "title")
			Result.put_boolean (a_completed, "completed")
			Result.put_integer (a_order, "order")
		end

end
