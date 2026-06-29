note
	description: "[
	* {RESTLY_VERBS_BASIC_MUTABLE} Raw mutable Store Protocol.
	item returns a direct reference to the stored value.
	Prefer RESTLY_VERBS_BASIC (immutable-by-default) unless you
	specifically need to avoid the deep_twin overhead.
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	RESTLY_VERBS_BASIC_MUTABLE[K->HASHABLE,V]

inherit
	V_HASH_TABLE[K,V]
		rename
			item as mutable_item,
			default_create as v_table_default_create,
			make as v_table_make,
			copy as v_table_copy
		export
			{RESTLY_VERBS_BASIC_MUTABLE} mutable_item
			{NONE} v_table_default_create, v_table_make, v_table_copy
		end

end
