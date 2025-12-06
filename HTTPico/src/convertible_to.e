note
	description: "Summary description for {CONVERTIBLE_TO}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CONVERTIBLE_TO[S -> attached ANY]

convert
to_s:{S}


feature -- Conversion

	to_s:S
		-- Convert to type S
	deferred
	end

	make_from_s(a_s:S)
	deferred
	end

end
