note
	description: "Summary description for {PICO_PATH_TABLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	PICO_PATH_TABLE[R -> attached ANY, P]

inherit
	HASH_TABLE [R, STRING]
	rename
		item as hash_item,
		extend as hash_extend,
		linear_representation as hash_linear_representation,
		has as hash_has,
		force as hash_force,
		remove as hash_remove
	export
		{NONE} all
		{ANY} hash_has
	undefine
		empty_duplicate
	end

	PICO_VERBS[R,P]
	undefine
		copy, is_equal
	end

feature -- Query

	item alias "/" (key: PATH): R assign force
		local
			l_key: STRING
			l_result: detachable R
		do
			l_key := path_to_string(key)
			l_result := hash_item(l_key)
			if attached l_result as l_item then
				Result := l_item
			else
				-- This should not happen if precondition is checked
				check False then
					-- Will fail here with precondition message
				end
			end
		end

	has (key: PATH): BOOLEAN
		do
			Result := hash_has(path_to_string(key))
		end

	linear_representation: LIST[R]
		local
			l_list: ARRAYED_LIST[R]
		do
			create l_list.make (count)
			across hash_linear_representation as ic loop
				l_list.extend (ic)
			end
			Result := l_list
		end

	extend (v: R)
		local
			l_key: PATH
			l_string_key: STRING
		do
			l_key := key_for(v)
			l_string_key := path_to_string(l_key)
			put(v, l_string_key)
			last_modified_key := l_key
		end

	force (v: R; key: PATH)
		do
			hash_force(v, path_to_string(key))
			last_modified_key := key
		end

	remove (key: PATH)
		do
			hash_remove(path_to_string(key))
		end

feature {NONE} -- Implementation

	path_to_string (a_path: PATH): STRING
			-- Convert PATH to STRING for hash table operations
		do
			Result := a_path.name.to_string_8
		end

	empty_duplicate (n: INTEGER): like Current
		deferred
		end

end
