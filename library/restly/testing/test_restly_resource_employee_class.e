note
	description: "RESTLY_RESOURCE [STRING, EMPLOYEE, PERSON] tested via EMPLOYEE_PERSON_CONVERTER."
	author: "agarciafdz@gmail.com"

class
	TEST_RESTLY_RESOURCE_EMPLOYEE_CLASS

inherit
	TEST_RESTLY_RESOURCE_EMPLOYEE
		redefine
			test_extend_then_has_key,
			test_item_preserves_name,
			test_item_id_follows_converter_round_trip,
			test_force_on_new_key,
			test_force_overwrites_existing,
			test_put_updates_existing,
			test_remove_deletes_key
		end
	EQA_TEST_SET

feature {NONE} -- Fixture

	conv: RESTLY_CONVERTER [EMPLOYEE, PERSON]
		attribute create {EMPLOYEE_PERSON_CONVERTER} Result end

feature -- Tests

	test_extend_then_has_key         do Precursor end
	test_item_preserves_name         do Precursor end
	test_item_id_follows_converter_round_trip     do Precursor end
	test_force_on_new_key            do Precursor end
	test_force_overwrites_existing   do Precursor end
	test_put_updates_existing        do Precursor end
	test_remove_deletes_key          do Precursor end

end
