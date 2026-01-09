class PICO_PATH_TABLE_UNCONSTRAINED [R]

inherit
	PICO_REQUEST_METHODS_UNCONSTRAINED [R]
		undefine copy, is_equal
		end
	HASH_TABLE [R, PATH_PICO]
		rename
			extend as keyed_extend,
			item as hash_item
		end

create
	make

feature -- Queries
	options: LIST [STRING]
		once
			create {ARRAYED_LIST [STRING]} Result.make_from_array (<<"HEAD", "GET", "POST", "PUT", "PATCH", "DELETE">>) end

    item alias "[]" (key: PATH_PICO): R assign force
			-- Equivalent to http GET /key
			-- Requests a resource representation; retrieves data only.
		do
            check attached hash_item(key) as l_item then
                Result := l_item
            end
        end

	key_for (data: R): PATH_PICO
			-- Generate timestamp-based key in format: yyyymmdd_hhmmss
		local
			dt: DATE_TIME
		do
			create dt.make_now
			create Result.make_from_string (dt.formatted_out ("yyyy[0]mm[0]dd_[0]hh[0]mi[0]ss"))
		end

    
feature -- Commands
	extend (data: R)
		do
			last_inserted_key := key_for (data)
			force (data, last_inserted_key)
		end

	extend_with_patch (a_patch: TABLE_ITERABLE [detachable ANY, STRING])
			-- Not supported for non-patchable types
		do
			-- Cannot implement for arbitrary R without PATCHABLE constraint
			check False then end
		end

	patch (a_patch: TABLE_ITERABLE [detachable ANY, STRING]; key: PATH_PICO)
			-- Not supported for non-patchable types
		do
			-- Cannot implement for arbitrary R without PATCHABLE constraint
			check False then end
		end


end
