class TODO_ITEM_PATCHABLE

inherit
	TODO_ITEM_CONVERTIBLE
	PATCHABLE
		undefine
			is_equal
		end

create
	make_empty,
	make_from_json_value,
	make_from_string_32,
	make_from_patch

convert
	make_from_json_value ({JSON_VALUE}),
	make_from_string_32 ({STRING_32}),
	to_json_value: {JSON_VALUE},
	to_string_32: {STRING_32}

feature -- Access

	patch_fields: ARRAY[STRING]
		once
			Result := <<"title", "completed", "order">>
		end

feature {NONE} -- Implementation

	field_setter (a_value: ANY; a_key: STRING)
			-- Set field identified by `a_key` to `a_value`
		do
			if a_key.same_string ("title") then
				if attached {STRING_32} a_value as l_title then
					title := l_title
				end
			elseif a_key.same_string ("completed") then
				if attached {BOOLEAN_REF} a_value as l_completed then
					completed := l_completed.item
				end
			elseif a_key.same_string ("order") then
				if attached {INTEGER_REF} a_value as l_order then
					order := l_order.item
				end
			end
		end

end
