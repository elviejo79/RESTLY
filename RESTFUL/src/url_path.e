note
	description: "Summary description for {URL_PATH}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	URL_PATH

inherit
	PATH


create
	make_from_string,
	make_from_separate

convert
	make_from_string ({STRING}),
	out: {READABLE_STRING_GENERAL}

--feature
--	hash_code: INTEGER_32
--		do
--			Result := out.hash_code
--		end

end
