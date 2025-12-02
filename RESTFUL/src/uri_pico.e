note
	description: "Summary description for {URL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	URI_PICO

inherit
	URI

	HASHABLE
	CONVERTIBLE_TO[READABLE_STRING_GENERAL]
	rename
		to_s as to_string
	end

create
	make_from_string

convert
	make_from_string({STRING}),
	string: {READABLE_STRING_GENERAL}

feature -- to make it hashable
	hash_code:INTEGER_32
	do
		Result := string.hash_code
	end

feature
	to_string:READABLE_STRING_GENERAL
	do
		Result := out
	end
end
