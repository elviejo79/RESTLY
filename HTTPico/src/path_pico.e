note
	description: "Summary description for {PATH_OR_STRING}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PATH_PICO

inherit
	PATH
      redefine
      make_from_separate
      end


create
	make_from_string,
	make_from_separate,
	make_from_path

convert
	make_from_string ({STRING}),
	make_from_path ({PATH}),
	out: {READABLE_STRING_GENERAL}

feature
   make_from_separate(a_path: separate PATH)
      local
      s : STRING
      do
        create s.make_from_separate(a_path.out)
        make_from_string(s)
      end

   make_from_path(a_path: PATH)
      do
        make_from_string(a_path.out)
      end

end
