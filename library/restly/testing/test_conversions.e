note
	description: "Tests for PERSON <-> EMPLOYEE conversion behaviour."
	author: "agarciafdz@gmail.com"
	date: "$Date$"
	revision: "$Revision$"

class
   TEST_CONVERSIONS

inherit
   EQA_TEST_SET

feature -- Tests

   test_explicit_to_person
         -- calling to_person directly (outgoing conversion feature)
      local
         e: EMPLOYEE
         p: PERSON
      do
         create e.make ("Alice", 42)
         p := e.to_person
         assert ("name preserved", p.name ~ "Alice")
      end

   test_explicit_from_person
         -- calling make_from_person directly (incoming conversion feature)
      local
         p: PERSON
         e: EMPLOYEE
      do
         create p.make ("Bob")
         create e.make_from_person (p)
         assert ("name preserved", e.name ~ "Bob")
         assert ("id defaults to 0", e.employee_id = 0)
      end

   test_implicit_employee_to_person
         -- plain assignment: compiler inserts e.to_person
      local
         e: EMPLOYEE
         p: PERSON
      do
         create e.make ("Carol", 99)
         p := e
         assert ("name preserved", p.name ~ "Carol")
      end

   test_implicit_person_to_employee
         -- plain assignment: compiler inserts create e.make_from_person(p)
      local
         p: PERSON
         e: EMPLOYEE
      do
         create p.make ("Dave")
         e := p
         assert ("name preserved", e.name ~ "Dave")
         assert ("id defaults to 0", e.employee_id = 0)
      end

   test_roundtrip_employee_person_employee
         -- EMPLOYEE -> PERSON -> EMPLOYEE preserves name, loses id
      local
         e1, e2: EMPLOYEE
         p: PERSON
      do
         create e1.make ("Eve", 7)
         p := e1
         e2 := p
         assert ("name survives roundtrip", e2.name ~ "Eve")
         assert ("id lost in roundtrip", e2.employee_id = 0)
      end

end
