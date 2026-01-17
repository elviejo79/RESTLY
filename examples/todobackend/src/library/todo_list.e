note
	description: "Summary description for {TODO_LIST}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

once class
	TODO_LIST

inherit
	PICO_PATH_TABLE[TODO_ITEM, JSON_OBJECT]


create
	make_default

feature -- Initialization
	make_default
	once
		make(10)
		create last_modified_key.make_from_string("")
	end

feature -- Implementation of PICO_VERBS


	patch (a_jo: JSON_OBJECT; key: PATH)
		local
			l_item: TODO_ITEM
		do
			l_item := item(key)
			l_item.patch({TODO_ITEM}.tuple_from_json_object(a_jo))
			last_modified_key := key
		end

	extend_from_patch (a_jo: JSON_OBJECT)
		local
			l_item: TODO_ITEM
		do
			create l_item.make_from_patch({TODO_ITEM}.tuple_from_json_object(a_jo))
            extend(l_item)
            l_item.key := last_modified_key
		end

	key_for (v: TODO_ITEM): PATH
		local
			l_count_string: STRING_8
		do
			if attached v.key as l_key and then not l_key.is_empty then
				Result := l_key
			else
				l_count_string := count.out.to_string_8
				create Result.make_from_string(l_count_string)
			end
		end

feature {NONE} -- Implementation

	empty_duplicate (n: INTEGER): like Current
		do
			Result := Current
		end
end
