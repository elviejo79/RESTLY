note
	description: "REST verbs implemented by V_HASH_TABLE."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	RESTLY_HASH_TABLE [K -> HASHABLE, V]

inherit
	RESTLY_LISTABLE [K, V]
		undefine
			force
		end

	V_HASH_TABLE [K, V]

create
	default_create,
	with_object_equality

end
