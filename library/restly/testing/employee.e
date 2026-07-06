note
	description: "[
                {EMPLOYEE} has no inheritance from {PERSON}.
                Declares both conversion directions:
                   make_from_person ({PERSON})  -- incoming: PERSON -> EMPLOYEE
                   to_person: {PERSON}          -- outgoing: EMPLOYEE -> PERSON
                ]"
	author: "agarciafdz@gmail.com"
	date: "$Date$"
	revision: "$Revision$"

class
   EMPLOYEE

create
   make,
   make_from_person

convert
   make_from_person ({PERSON}),
   to_person: {PERSON}

feature -- Access

   name: STRING
   employee_id: INTEGER

feature -- Creation

   make (a_name: STRING; an_id: INTEGER)
      do
         name := a_name
         employee_id := an_id
      end

   make_from_person (a_person: PERSON)
      do
         name := a_person.name
         employee_id := 0
      end

feature -- Conversion

   to_person: PERSON
      do
         create Result.make (name)
      end

end
