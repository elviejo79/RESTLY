note
	description: "Helper converter for TEST_RESTLY_RESOURCE_EMPLOYEE_CLASS. Converts EMPLOYEE <-> PERSON."
	author: "agarciafdz@gmail.com"

class
	EMPLOYEE_PERSON_CONVERTER

inherit
	RESTLY_CONVERTER [EMPLOYEE, PERSON]

create
	default_create

feature -- Conversion

	to_store (e: EMPLOYEE): PERSON
		do
			create Result.make (e.name)
		end

	to_representation (p: PERSON): EMPLOYEE
		do
			create Result.make (p.name, p.name.hash_code)
		end

end
