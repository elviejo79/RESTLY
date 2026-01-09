
class
	PICO_FILE_CLIENT[R -> STRING create make_from_string end]

inherit
	PICO_SCHEME_HANDLER [R]
		undefine
			has_item
		redefine
			can_connect,
			base_uri
		end

	DIRECTORY
		rename
			entries as keys,
			make as directory_make,
			make_with_path as directory_make_with_path
		export
			{none} all
		end

create
	make

feature {NONE} -- Initialization

	make (a_root: FILE_URL)
			-- Initialize with URL
		do
			base_uri := a_root
			root := a_root
			directory_make_with_path (a_root.file_path)
		end

feature -- Attributes

	base_uri: FILE_URL
			-- Redefine to be more specific type

	Valid_scheme: ARRAY[STRING_8]
			-- This client handles file:// URLs
		once
			Result := << "file" >>
			Result.compare_objects
		end
feature -- Queries aka HTTP safe verbs

	can_connect (a_uri: FILE_URL): BOOLEAN
			-- Can we connect to the directory at `a_uri`?
			-- For FILE_SCHEME, this means the directory must exist.
		local
			dir: DIRECTORY
		do
			create dir.make_with_path (a_uri.file_path)
			Result := dir.exists
		end

	has_key (key: PATH_PICO): BOOLEAN
			-- Does file exist?
		do
			Result := has_entry (key.name)
		end

	item alias "[]" (key: PATH_PICO): R assign force
			-- Equivalent to HTTP GET: get file contents.
		local
			f: PLAIN_TEXT_FILE
		do
			create f.make_with_path (path.extended_path (key))
			f.open_read
			if f.count > 0  then
			  	f.read_stream (f.count)
				create Result.make_from_string(f.last_string.twin)
			else
				create Result.make_from_string("")
			end
			f.close
		end

feature -- Commands aka HTTP unsafe verbs

	collection_extend (data: R)
			-- Equivalent to HTTP POST.
			-- Submits `data`; may change state or cause side effects.
		local
			l_key: PATH_PICO
		do
			l_key := new_post_key (data)
			internal_write (l_key, data)
			last_inserted_key_internal := l_key
		end

	force (data: R; key: PATH_PICO)
			-- Equivalent to HTTP PUT.
			-- Replaces the resource's representation with the request content.
			-- If `key` didn't exist it inserts it.
		do
			internal_write (key, data)
			last_inserted_key_internal := key
		ensure then
			data_stored_or_throw_507_insufficient_storage: item (key) /= Void
		end

	remove (key: PATH_PICO)
			-- Equivalent to HTTP DELETE: remove specified resource.
		local
			f: PLAIN_TEXT_FILE
		do
			create f.make_with_path (path.extended_path (key))
			if f.exists then
				f.delete
			end
		end

feature -- Helpers

	last_inserted_key: PATH_PICO
			-- Last key created/modified by POST or PUT.
			-- No pure HTTP equivalent; needed for CQS in Eiffel.
		do
			check attached last_inserted_key_internal as k then
				Result := k
			end
		end

	has_item (data: R): BOOLEAN
			-- Does any file in `root` directory have contents equal to `data`?
			-- No HTTP equivalent; helper for Eiffel-level contracts.
		local
			k: PATH
			k_conv: PATH_PICO
			v: R
		do
			across
				keys as c
			until
				Result
			loop
				k := c.item
				create k_conv.make_from_string(k.out)
				if has_key (k_conv) then
					v := item (k_conv)
					if v.same_string (data) then
						Result := True
					end
				end
			end
		end

	all_keys: ITERABLE [PATH_PICO]
			-- All keys (file names) in this directory
		local
			keys_list: ARRAYED_LIST [PATH_PICO]
			entry_path: detachable PATH
			entry_name: STRING_8
		do
			create keys_list.make (10)
			open_read
			across keys as k loop
				entry_path := k.item.entry
				if attached entry_path and then not entry_path.name.starts_with (".") then
					entry_name := entry_path.name.to_string_8
					keys_list.extend (create {PATH_PICO}.make_from_string (entry_name))
				end
			end
			close
			Result := keys_list
		end

feature {NONE} -- Implementation

	root: FILE_URL
			-- Base directory for generated files (POST/PUT).

	last_inserted_key_internal: detachable PATH_PICO
			-- Backing field for `last_inserted_key`.

	new_post_key (data: R): PATH_PICO
			-- Key under `root` for POST; name is SHA-256 of `data`.
		local
			digest: STRING
			p:PATH
		do
			digest := sha256_hex (data)
			create p.make_empty
			create Result.make_from_string((p.appended (digest).appended_with_extension ("txt")).out)

		end

	internal_write (key: PATH_PICO; data: STRING)
			-- Write `data` into file identified by `key`.
		local
			f: PLAIN_TEXT_FILE
		do
			create f.make_with_path (path.extended_path (key))
			if f.exists then
				f.open_write
			else
				f.create_read_write
			end
			f.put_string (data)
			f.close
		end

	is_plain_file (p: PATH): BOOLEAN
			-- Is `p` a regular (plain) file?
		local
			info: FILE_INFO
		do
			create info.make
			info.update (p.name)
			Result := info.exists and then info.is_plain
		end

	sha256_hex (data: STRING): STRING
			-- Hexadecimal SHA-256 digest of `data`.
			-- Requires `crypto` library (class SHA256).
		local
			hash: SHA256
		do
			create hash.make
			hash.update_from_string (data)
			Result := hash.digest_as_string
				-- Result := "fixed_name"
		end

invariant
	root_not_void: root /= Void

end
