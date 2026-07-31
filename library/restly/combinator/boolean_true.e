note
	description: "Constant combinator: every verb reports True."
	author: "agarciafdz@gmail.com"

class
	BOOLEAN_TRUE [K -> HASHABLE, V]

inherit
	BOOLEAN_INTERFACE [K, V]

feature -- Queries

	has_key (k: K): BOOLEAN
		do
			Result := True
		end

	item alias "[]" (k: K): BOOLEAN
		do
			Result := True
		end

feature -- Commands as reports

	extend (v: V; k: K): BOOLEAN
		do
			Result := True
		end

	force (v: V; k: K): BOOLEAN
		do
			Result := True
		end

	put (v: V; k: K): BOOLEAN
		do
			Result := True
		end

	remove (k: K): BOOLEAN
		do
			Result := True
		end

	merge (a_patch: JSON_OBJECT; a_k: K): BOOLEAN
		do
			Result := True
		end

end
