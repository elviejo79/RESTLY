note
	description: "Summary description for {URL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	URL

inherit
	URI
--	rename
----		path as string_path
----	export
----		{NONE}
----		string_path,
----		path_segment,
----		path_segment_count,
----		path_segments
--	end

	HASHABLE

create
	make_from_string

convert
	make_from_string({STRING}),
	string: {READABLE_STRING_GENERAL}

feature -- to make it hashable
	hash_code:INTEGER_32
	do
		Result := string.hash_code
	end

--feature
--	path: attached URL_PATH
--	once
--		create Result.make_from_string(string_path)
--	end
end
