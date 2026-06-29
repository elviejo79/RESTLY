note
	description: "[
	{RESTLY_VERBS} Analogous to HTTP Request verbs:
	 Head, Get, Put, Delet, Post, Patch
	 The goal is that most RESOURCE would implement this protocol and if for some reason they are incomplete,
	 then thy would select if that resourse is basic (only 4 verbs) or basic+patchable or basic+extendable
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	RESTLY_VERBS[K->HASHABLE,V]

inherit
	RESTLY_VERBS_BASIC[K,V]

	RESTLY_VERBS_EXTENDABLE[K,V]

	RESTLY_VERBS_PATCHABLE[K,V]


end
