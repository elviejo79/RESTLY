note
	description: "Summary description for {PICO_PATH_TABLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	PICO_PATH_TABLE[R -> attached ANY, P]

inherit
	HASH_TABLE [R, PATH]
	rename
		item as hash_item,
		extend as hash_extend,
		linear_representation as hash_linear_representation
	export
		{NONE} all
	undefine
		empty_duplicate
	end

	PICO_VERBS[R,P]
	undefine
		copy, is_equal
	end

feature -- Query

	item alias "/" (key: PATH): R assign force
		do
			check attached {R} hash_item(key) as l_res then
				Result := l_res
			end
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
		do
			l_key := key_for(v)
			hash_extend(v, l_key)
			last_modified_key := l_key
		end


feature {NONE} -- Implementation

	empty_duplicate (n: INTEGER): like Current
		deferred
		end

end
