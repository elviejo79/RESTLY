note
	description: "Summary description for {RESTLY_VERBS_PATCHABLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	RESTLY_VERBS_PATCHABLE[K->HASHABLE,V]
	inherit
		RESTLY_VERBS_BASIC[K,V]

feature
patch (a_patch:TUPLE;k:K)
		--a_pathch is by definition an incomplete object that can be used to update values
	note
			modify: map
		require
			has_key: has_key (k)
		deferred
		ensure
			map_effect: map |=| old map.updated (k,patch_as_value(a_patch))
		end

feature --user defined
	patch_as_value:FUNCTION[TUPLE,V]


end
