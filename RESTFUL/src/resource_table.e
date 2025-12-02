note
	description: "Summary description for {RESOURCE_TABLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	RESOURCE_TABLE [R -> attached ANY]

inherit
	REST_TABLE [R]
		undefine
			is_equal, copy
		end

	HTTPICO_RESOURCE
		redefine
			make_with_url
		end

create
	make,
	make_with_url

feature {NONE}
	make_with_url (a_url: URI)
		do
			make (10)
			Precursor (a_url)
		end

end
