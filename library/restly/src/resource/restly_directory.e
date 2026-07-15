note
	description: "[
		A filesystem directory as a RESTLY store.
		Keys are relative paths under the root; values are file contents (bytes).
		Percent-encoded template characters land literally in filesystem paths;
		spaces and Unicode filenames are unsupported in v1.
	]"

class
	RESTLY_DIRECTORY

inherit
	RESTLY_PROTOCOL [RESTLY_URI_PATH, STRING]
		redefine
			force
		end

	RESTLY_FILE_NODE

	RESTLY_ADDRESSABLE
		undefine
			is_equal, copy, out
		end

create
	make_with_base_url,
	make_with_path

feature {NONE} -- Initialization

	make_with_base_url (a_url: RESTLY_FILE_URI)
			-- From a strict file:/// URI, e.g. "file:///home/me/dir/".
			-- RESTLY_FILE_URI invariant guarantees "file:///" prefix;
			-- path is everything after "file://" (the leading "/" stays).
		local
			l_path: STRING
		do
			l_path := a_url.template.to_string_8.substring (8, a_url.template.count)
			if l_path.count > 1 and then l_path.ends_with ("/") then
				l_path.remove_tail (1)
			end
			make_from_string (l_path)
		end

	make_with_path (a_path: PATH)
			-- From an absolute filesystem path.
		do
			make_from_separate (a_path)
		end

feature -- Access

	exists: BOOLEAN
			-- Does a directory exist at this path?
		local
			d: DIRECTORY
		do
			create d.make_with_path (Current)
			Result := d.exists
		end

feature -- REST verbs

	has_key (k: RESTLY_URI_PATH): BOOLEAN
			-- Does a plain file exist at `k` under this directory?
		local
			f: RAW_FILE
		do
			create f.make_with_path (file_system_path (k))
			Result := f.exists and then f.is_plain
		end

	item alias "[]" (k: RESTLY_URI_PATH): STRING assign force
			-- Contents of the file at `k`.
		local
			f: RAW_FILE
		do
			create f.make_with_path (file_system_path (k))
			f.open_read
			f.read_stream (f.count)
			Result := f.last_string
			f.close
		end

	force (v: STRING; k: RESTLY_URI_PATH)
			-- Write `v` to the file at `k` (creates or truncates).
		require else
			error_409_conflict: True
					-- TODO(owner): contract
					-- suggested: parent_directory_exists (k) and then not is_directory_entry (k)
					-- (WebDAV RFC 4918 §9.7.1: PUT must not create intermediate collections)
		local
			f: RAW_FILE
		do
			create f.make_with_path (file_system_path (k))
			f.open_write
			f.put_string (v)
			f.close
		end

	put (v: STRING; k: RESTLY_URI_PATH)
			-- Overwrite existing file at `k`.
		do
			force (v, k)
		end

	extend (v: STRING; k: RESTLY_URI_PATH)
			-- Create a new file at `k` (must not already exist).
		do
			force (v, k)
		end

	remove (k: RESTLY_URI_PATH)
			-- Delete the file at `k`.
		local
			f: RAW_FILE
		do
			create f.make_with_path (file_system_path (k))
			f.delete
		end

feature -- Navigation

	node (a_path: STRING): RESTLY_FILE_NODE
			-- Node at `a_path` (leading "/", key-style): a RESTLY_DIRECTORY
			-- or RESTLY_FILE depending on what is on disk; caller object-tests.
		require
			error_404_not_found: True
					-- TODO(owner): contract
					-- suggested: node exists on disk
		local
			f: RAW_FILE
			l_full: PATH
		do
			create l_full.make_from_string (utf_8_name + a_path)
			create f.make_with_path (l_full)
			if f.is_directory then
				create {RESTLY_DIRECTORY} Result.make_with_path (l_full)
			else
				create {RESTLY_FILE} Result.make_with_path (l_full)
			end
		end

	subdirectory alias "/" (a_segment: STRING): RESTLY_DIRECTORY
			-- Directory rooted at Current/`a_segment`.
		require
			error_404_not_found: True
					-- TODO(owner): contract
					-- suggested: (create {DIRECTORY}.make_with_path (extended (a_segment))).exists
			error_409_conflict: True
					-- TODO(owner): contract
					-- suggested: not (create {RAW_FILE}.make_with_path (extended (a_segment))).is_plain
		do
			create Result.make_with_path (extended (a_segment))
		end

feature -- Traversal

	entries: ITERABLE [RESTLY_FILE_NODE]
			-- One node per directory entry ("." and ".." skipped).
			-- Nodes carry absolute paths; reconstruct protocol keys
			-- as "/" + node.name if needed.
			-- ponytail: eager list, lazy contents; cursor class if 10k+ entries matter
		require
			error_404_not_found: True
					-- TODO(owner): contract
					-- suggested: exists
		local
			d: DIRECTORY
			list: ARRAYED_LIST [RESTLY_FILE_NODE]
			f: RAW_FILE
			l_full: PATH
		do
			create d.make_with_path (Current)
			create list.make (16)
			across d.entries as e loop
				if not e.is_current_symbol and not e.is_parent_symbol then
					l_full := Current + e
					create f.make_with_path (l_full)
					if f.is_directory then
						list.extend (create {RESTLY_DIRECTORY}.make_with_path (l_full))
					else
						list.extend (create {RESTLY_FILE}.make_with_path (l_full))
					end
				end
			end
			Result := list
		end

feature {NONE} -- Implementation

	file_system_path (k: RESTLY_URI_PATH): PATH
			-- Absolute path for key `k`: root + relative reference.
			-- Keys carry their leading "/" per RESTLY_URI_PATH convention,
			-- which PATH.extended rejects (has_root); build via string.
		require
			error_400_bad_request: True
					-- TODO(owner): contract
					-- suggested: not k.template.has_substring ("..")
					--            and not k.template.has ('{')
					--            and not k.template.has ('?')
		do
			create Result.make_from_string (utf_8_name + k.template)
		end

end
