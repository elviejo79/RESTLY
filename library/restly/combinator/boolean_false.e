note
	description: "Constant combinator: every verb reports False."
	author: "agarciafdz@gmail.com"

class
	BOOLEAN_FALSE [K -> HASHABLE, V]

inherit
	BOOLEAN_INTERFACE [K, V]

feature -- Queries

	has_key (k: K): BOOLEAN
		do
		end

	item alias "[]" (k: K): BOOLEAN
		do
		end

feature -- Commands as reports

	extend (v: V; k: K): BOOLEAN
		do
		end

	force (v: V; k: K): BOOLEAN
		do
		end

	put (v: V; k: K): BOOLEAN
		do
		end

	remove (k: K): BOOLEAN
		do
		end

	merge (a_patch: JSON_OBJECT; a_k: K): BOOLEAN
		do
		end

end
