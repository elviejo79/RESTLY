note
	description: "[
			Eiffel tests that can be executed by testing tool.
		]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TEST_DIRECTORY_RESOURCE

inherit
	EQA_TEST_SET

feature -- Test routines

	test_directory
		local
			first, second: TUPLE [name: STRING; content: STRING]
			dir, other, different: DIRECTORY_RESOURCE
		do
			first := ["first.txt", "Content of first file"]
			second := ["second.txt", "Content of second file"]
			dir := {DIRECTORY_RESOURCE}.make_and_register (file_path)
			dir [first.name] := first.content
			assert ("we must have the content stored", first.content ~ dir [first.name])
			dir.remove (first.name)
			dir [second.name] := second.content
			assert ("we must have the content stored", second.content ~ dir [second.name])
			dir.remove (second.name)
			-- assert ("we shouldn't have any directory", 0 ~ dir.entries.count)
		end

feature -- test values
	file_path: URL
		attribute
			create Result.make_from_string ("file:///home/agarciafdz/exp_resources")
		end

end

