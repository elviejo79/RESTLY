note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TEST_REST_TABLE

inherit
	EQA_TEST_SET

feature -- Test routines

	test_assignment
		local
			tbl : REST_TABLE[STRING]
		do
			create tbl.make (3)
			tbl["/sub/dir"] := first
			assert("value was stored", first = tbl["/sub/dir"])
			tbl["/another"] := second
			tbl["/sub/dir"] := third
			assert("value was replaced", third = tbl["/sub/dir"])

		end

	test_resource_table
	local
		tbl,other,different : RESOURCE_TABLE[STRING]
	do
		tbl := {RESOURCE_TABLE[STRING]}.make_and_register(dot_com)
		other := {RESOURCE_TABLE[STRING]}.make_and_register (dot_com)
		tbl["\sub\dir"] := first
		assert("other and tbl must point to *exactly* the same resource", first = other["\sub\dir"])
		different := {RESOURCE_TABLE[STRING]}.make_and_register (dot_org)
		different["\sub\dir"] := first
		assert("resources should be different, even if values are identical", tbl /~ different and tbl["\sub\dir"] = different["\sub\dir"])


	end

feature -- example values
	first :STRING = "1st string"
	second:STRING = "2nd string"
	third:STRING = "3rd string"
	dot_com:URL
	attribute
		create Result.make_from_string("http://www.example.com")
	end

	dot_org:URL
	attribute
		create Result.make_from_string("http://www.example.org")
	end
end


