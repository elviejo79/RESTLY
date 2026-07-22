note
	description: "[
		Deferred ancestor for filesystem nodes (files and directories).
		Extends PATH with `exists` semantics per node kind.
	]"

deferred class
	RESTLY_FILE_NODE

inherit
	PATH
		rename
			name as full_name
		end

feature -- Access

	name: IMMUTABLE_STRING_32
			-- Last segment of the path.
		do
			if attached entry as l_entry then
				Result := l_entry.name
			else
				Result := full_name
			end
		end

	exists: BOOLEAN
			-- Does this node exist on disk (as its own kind)?
		deferred
		end

invariant
	path_is_absolute: True
			-- TODO(owner): contract
			-- suggested: is_absolute

end
