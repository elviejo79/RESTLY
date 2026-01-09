deferred class PATCHABLE

feature -- Access

	patch_fields: ARRAY[STRING]
		deferred
		end

feature -- Initialization

	make_empty
		deferred
		end

	make_from_patch (a_patch_list: HASH_TABLE[detachable ANY, STRING])
		local
			l_value: detachable ANY
		do
			make_empty
			from
				a_patch_list.start
			until
				a_patch_list.after
			loop
				l_value := a_patch_list.item_for_iteration
				if attached l_value as v then
					field_setter (v, a_patch_list.key_for_iteration)
				end
				a_patch_list.forth
			end
		end

	update_from_patch (a_patch_list: HASH_TABLE[detachable ANY, STRING])
		local
			l_value: detachable ANY
		do
			from
				a_patch_list.start
			until
				a_patch_list.after
			loop
				l_value := a_patch_list.item_for_iteration
				if attached l_value as v then
					field_setter (v, a_patch_list.key_for_iteration)
				end
				a_patch_list.forth
			end
		end

feature {NONE} -- Implementation

	field_setter (a_value: ANY; a_key: STRING)
			-- Set field identified by `a_key` to `a_value`
		deferred
		end

end
