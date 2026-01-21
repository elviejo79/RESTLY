note
	description: "Application-specific storage for TODO_ITEMs"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

once class
	TODO_LIST

inherit
	PICO_PATH_TABLE[TODO_ITEM, TUPLE]


create
	make_default

feature -- Initialization
	make_default
	once
		make(10)
		create last_modified_key.make_from_string("")
	end

feature -- Implementation of PICO_VERBS

	patch_ds: TUPLE[title: detachable STRING; completed: detachable BOOLEAN_REF; order: detachable INTEGER_REF]
		do
			Result := [Void, Void, Void]
		end

	patch (a_patch: like patch_ds; key: PATH)
		local
			l_item: TODO_ITEM
		do
			l_item := item(key)
			l_item.patch(a_patch)
			last_modified_key := key
		end

	extend_from_patch (a_patch: like patch_ds)
		local
			l_item: TODO_ITEM
		do
			create l_item.make_from_patch(a_patch)
			extend(l_item)
		end

	key_for (v: TODO_ITEM): PATH
		local
			l_count_string: STRING_8
		do
			l_count_string := count.out.to_string_8
			create Result.make_from_string(l_count_string)
		end

feature {NONE} -- Implementation

	empty_duplicate (n: INTEGER): like Current
		do
			Result := Current
		end
end
