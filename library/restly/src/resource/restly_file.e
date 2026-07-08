note
	description: "[
		A single file on disk — the CELL-shaped micro-store.
		item reads bytes, put writes them, remove deletes the file.
		Not protocol-conforming: appears only in navigation and traversal.
		Percent-encoded template characters land literally in paths.
	]"

class
	RESTLY_FILE

inherit
	RESTLY_FILE_NODE

create
	make_with_path

feature {NONE} -- Initialization

	make_with_path (a_path: PATH)
			-- Initialize for file at `a_path`.
		do
			make_from_separate (a_path)
		end

feature -- Access

	item: STRING
			-- File contents as bytes.
		require
			error_404_not_found: True
					-- TODO(owner): contract
					-- suggested: exists
		local
			f: RAW_FILE
		do
			create f.make_with_path (Current)
			f.open_read
			f.read_stream (f.count)
			Result := f.last_string
			f.close
		end

	exists: BOOLEAN
			-- Does a plain file exist at this path?
		local
			f: RAW_FILE
		do
			create f.make_with_path (Current)
			Result := f.exists and then f.is_plain
		end

feature -- Element change

	put (v: STRING)
			-- Write `v` as the whole file contents (creates or truncates).
		local
			f: RAW_FILE
		do
			create f.make_with_path (Current)
			f.open_write
			f.put_string (v)
			f.close
		end

	remove
			-- Delete the file.
		require
			error_404_not_found: True
					-- TODO(owner): contract
					-- suggested: exists
		local
			f: RAW_FILE
		do
			create f.make_with_path (Current)
			f.delete
		end

end
