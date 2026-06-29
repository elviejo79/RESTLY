note
	description: "[
	{RESTLY_RESOURCE_EMPTY} is intended to provide void safety for combinators.
	but in fact any call to this should generate an exception
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	RESTLY_RESOURCE_EMPTY
	inherit
		RESTLY_VERBS_BASIC[HASHABLE,ANY]
			redefine
				has_key
			end

create
	default_create

feature -- Creation

	default_create
		do
			v_table_default_create
		end

feature -- Access

	has_key (k: HASHABLE): BOOLEAN
		do
			Result := False
		end

	item alias "[]" (k: HASHABLE): ANY assign force
		do
			check restly_resource_empty: False end
			Result := Current
		end

end
