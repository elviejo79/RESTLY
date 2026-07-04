note
	description: "Simple person with a name. No inheritance from EMPLOYEE."
	author: "agarciafdz@gmail.com"
	date: "$Date$"
	revision: "$Revision$"

class
   PERSON

create
   make

feature -- Access

   name: STRING

feature -- Creation

   make (a_name: STRING)
      do
         name := a_name
      end

end
