note
	description: "Tests for the error_NNN_description tag parser."

class
	TEST_TAG_PARSER

inherit
	EQA_TEST_SET

feature -- Tests

	test_error_404_not_found
		do
			assert ("404", handler.status_from_tag ("error_404_not_found") = 404)
		end

	test_error_403_forbidden
		do
			assert ("403", handler.status_from_tag ("error_403_forbidden") = 403)
		end

	test_error_409_conflict
		do
			assert ("409", handler.status_from_tag ("error_409_conflict") = 409)
		end

	test_error_500_internal
		do
			assert ("500", handler.status_from_tag ("error_500_internal_server_error") = 500)
		end

	test_no_match_returns_zero
		do
			assert ("no match", handler.status_from_tag ("some_other_tag") = 0)
		end

	test_error_prefix_no_number
		do
			assert ("no number", handler.status_from_tag ("error_abc_bad") = 0)
		end

	test_error_prefix_no_second_underscore
		do
			assert ("no underscore", handler.status_from_tag ("error_404") = 0)
		end

	test_empty_tag
		do
			assert ("empty", handler.status_from_tag ("") = 0)
		end

feature {NONE} -- Helpers

	handler: TEST_TAG_PARSER_HELPER
		local
			l_table: RESTLY_HASH_TABLE [STRING, JSON_OBJECT]
		once
			create l_table
			create Result.make (l_table)
		end

end
