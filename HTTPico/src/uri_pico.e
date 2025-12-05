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
	make_from_string,
	make_from_s

convert
	make_from_string({STRING}),
	string: {READABLE_STRING_GENERAL}

feature -- CONVERTIBLE_TO features
	make_from_s(a_s:READABLE_STRING_GENERAL)
	local
		s8: STRING_8
	do
		s8 := a_s.to_string_8
		make_from_string(s8)
	end

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
