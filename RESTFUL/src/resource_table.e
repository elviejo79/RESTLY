note
	description: "Summary description for {RESOURCE_TABLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	RESOURCE_TABLE[R]

inherit
	REST_TABLE [R]
	undefine
		is_equal,copy
	end

	RESOURCE
	redefine
		make_with_url
	end

create
	make,
	make_with_url

feature
	make_with_url(a_url:URL)
	do
		make(10)
		Precursor(a_url)
	end
end
