note
	description: "[
			Eiffel tests that can be executed by testing tool.
		]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TEST_DNS

inherit
	EQA_TEST_SET

feature -- Test routines

	test_dns
			-- New test routine
		local
			res, other, different: RESOURCE
		do
			res := {RESOURCE}.make_and_register (url_com)
			other := {RESOURCE}.make_and_register (url_com)
			assert ("res and other should be equivalent", res ~ other)
			assert ("res and other should be identical", res = other)

			different := {RESOURCE}.make_and_register (url_org)
			assert ("res and different should not be equivalent", not (res ~ different))
			assert ("res and different should be different", not (res = different))

		end

feature -- example values
	url_com: URL
		attribute
			create Result.make_from_string ("http://www.example.com")
		end
	url_org: URL
		attribute
			create Result.make_from_string ("http://www.example.org")
		end

end

