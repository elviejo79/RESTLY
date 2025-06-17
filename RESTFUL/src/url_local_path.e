note
	description: "Summary description for {URL_LOCAL_PATH}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	URL_LOCAL_PATH

inherit
	URL
--	rename
--		string_path as url_string_path
	undefine
		hier
	redefine
		make_from_string
	select
		make_from_string
	end
	PATH_URI
	rename
		make_from_string as file_make_from_string
	end

create
	make_from_string

feature
	make_from_string(a_file_path:STRING)
	do
		Precursor {URL}(a_file_path)
		file_make_from_string(a_file_path)

	end


end
