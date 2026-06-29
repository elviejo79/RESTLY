note
	description: "Summary description for {RESTLY_RESOURCE_BASIC_HASH}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	RESTLY_RESOURCE_BASIC_HASH[K -> HASHABLE, V -> attached ANY]

inherit
	RESTLY_VERBS_BASIC[K,V]

	V_HASH_TABLE[K,V]
		rename
			item as mutable_item
		select
			default_create, copy, make
		end

create
	default_create,
	with_object_equality

feature -- Access

	item alias "[]" (k: K): V assign force
		do
			Result := mutable_item (k).deep_twin
		end

end
