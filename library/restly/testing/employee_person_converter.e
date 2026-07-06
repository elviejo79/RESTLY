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
			-- Assignment fires {EMPLOYEE}'s convert clause (`to_person`).
		do
			Result := e
		end

	to_representation (p: PERSON): EMPLOYEE
			-- Assignment fires {EMPLOYEE}'s convert clause (`make_from_person`).
		do
			Result := p
		end

end
