note
	description: "Summary description for {DIRECTORY_RESOURCE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	DIRECTORY_RESOURCE

inherit

	PICO_RESOURCE
		redefine
			make_with_url
		select
			is_equal,
			copy
		end
	FILE_SCHEME[STRING]
	    rename
	    	make as file_scheme_make,
	    	is_equal as file_scheme_is_equal,
	    	copy as file_scheme_copy
	    end
create
	make_with_url

feature {NONE}
	make_with_url (a_dir: URI)
		local
			file_url: FILE_URL
		do
			if attached {FILE_URL} a_dir as path_uri then
				file_url := path_uri
			else
				create file_url.make_from_string (a_dir.string)
			end
			file_scheme_make(file_url)
			Precursor (a_dir)
		end

end
