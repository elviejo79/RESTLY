note
	description: "REST verbs implemented by V_HASH_TABLE."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	RESTLY_VERBS_HASH_TABLE [K -> HASHABLE, B]

inherit
	RESTLY_PROTOCOL [K, B]

	V_HASH_TABLE [K, B]

create
	default_create,
	with_object_equality

end
