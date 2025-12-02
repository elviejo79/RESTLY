note
	description: "Summary description for {CONVERTIBLE_TO}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CONVERTIBLE_TO[S -> attached ANY]

convert
   to_s:{S}

feature
	to_s:S
	deferred
	end

end
