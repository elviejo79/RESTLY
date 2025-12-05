note
	description: "Summary description for {FILE_URL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FILE_URL

inherit
	PATH_URI

	HASHABLE

create
	make_from_string

feature -- HASHABLE
	hash_code: INTEGER_32
		do
			Result := string.hash_code
		end

invariant
	scheme_is_file : "file" ~ scheme

end
