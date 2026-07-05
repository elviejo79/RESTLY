note
	description: "REST verbs implemented by V_HASH_TABLE."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	RESTLY_HASH_TABLE [K -> HASHABLE, V]

inherit
	RESTLY_TRAVERSABLE [K, V]

	V_HASH_TABLE [K, V]

create
	default_create,
	with_object_equality

end
