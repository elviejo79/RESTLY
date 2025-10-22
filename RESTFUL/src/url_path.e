note
	description: "Summary description for {URL_PATH}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	URL_PATH
      
inherit
	PATH
      redefine
      make_from_separate
      end


create
	make_from_string,
	make_from_separate

convert
	make_from_string ({STRING}),
	out: {READABLE_STRING_GENERAL}

feature
   make_from_separate(a_path: separate PATH)
      local
      s : STRING
      do
        create s.make_from_separate(a_path.out)
        make_from_string(s)
      end 

--feature
--	hash_code: INTEGER_32
--		do
--			Result := out.hash_code
--		end

end
