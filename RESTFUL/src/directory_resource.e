note
	description: "Summary description for {DIRECTORY_RESOURCE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	DIRECTORY_RESOURCE

inherit
	DIRECTORY
		rename
			is_equal as is_equal_dir,
			copy as copy_dir
		end
	RESOURCE
		redefine
			make_with_url
		select
			is_equal,
			copy
		end

	RESTLY [STRING]
		undefine
			is_equal,
			copy
		end

create
	make_with_url,
	make

feature {NONE}
	make_with_url (a_dir: URL)
		local
			file_url: PATH_URI
		do
			create file_url.make_from_file_uri (a_dir)
			make_with_path (file_url.file_path)
			Precursor (a_dir)
		end

feature
	prefixed (file: URL_PATH): STRING
		local
			temp: PATH
			address_path: PATH
		do
			create address_path.make_from_string (address.path)
			temp := file.absolute_path_in (address_path)
			Result := temp.out
		end

	current_file (a_path: URL_PATH): PLAIN_TEXT_FILE
		do
			create Result.make_with_name (prefixed (a_path))

		end
feature -- http verbs
--	has_key (a_path: URL_PATH): BOOLEAN
--	local
--			file: PLAIN_TEXT_FILE
--		do
--			Result := has_entry (prefixed (a_path))
--		end

	has_key (a_path: URL_PATH): BOOLEAN
		do
			Result := current_file (a_path).access_exists
		end

	item alias "[]" (a_path: URL_PATH): STRING assign force
		local
			file: PLAIN_TEXT_FILE
		do

			file := current_file (a_path)
			file.open_read
			file.read_stream (file.count)
			create Result.make_empty
			Result := file.last_string
			file.close
		end

	force (content: STRING; a_path: URL_PATH)
			-- Write `content` to the file at `a_path` in a single pass.
		do
			write_file (content, a_path)
		end

	remove (a_path: URL_PATH) local
			file: PLAIN_TEXT_FILE
		do
			file := current_file (a_path)
			file.open_write
			file.delete
			file.close

		end

	replace (content: STRING; key: URL_PATH)
			-- if we want to store files, without having a name for them
			-- we can just use thir hash as name
		do
			write_file (content, key)
			last_inserted_key := key
		end

	collection_extend (content: STRING)
			-- if we want to store files, without having a name for them
			-- we can just use thir hash as name
		local
			actual_key: URL_PATH
		do
			create actual_key.make_from_string (content.hash_code.out)
			write_file (content, actual_key)
			last_inserted_key := actual_key
		end

feature {NONE} -- Implementation

	write_file (content: STRING; a_path: URL_PATH)
			-- Write `content` to the file at `a_path` in a single pass.
		local
			file: PLAIN_TEXT_FILE
		do
			file := current_file (a_path)
			file.create_read_write
			file.put_string (content)
			file.close
		end

	last_inserted_key: URL_PATH
		attribute
			create Result.make_from_string ("")
		end

end
