note
	description: "[
		Keycard minted from a verified JWT: `sub` claim is the subject,
		`scope` claim (space-separated) maps onto the four queries.
		Write scope covers read by construction (ground rule 9);
		`is_valid` is structural only — never expiry (ground rule 4).
	]"

class
	JWT_CAPABILITY

inherit
	CAPABILITY

create
	make

feature {NONE} -- Initialization

	make (a_subject: PRINCIPAL; a_scopes: LIST [READABLE_STRING_32])
		do
			subject := a_subject
			create scopes.make (a_scopes.count)
			scopes.compare_objects
			from
				a_scopes.start
			until
				a_scopes.after
			loop
				scopes.extend (a_scopes.item.to_string_32)
				a_scopes.forth
			end
		end

feature -- Access

	subject: PRINCIPAL

	is_valid: BOOLEAN
			-- Structurally sound: a named subject.
		do
			Result := not subject.name.is_empty
		end

feature -- Queries (the protocol's verbs, collapsed)

	readable (a_key: HASHABLE): BOOLEAN
			-- Write covers read by construction (ground rule 9).
		do
			Result := has_scope ("read") or has_scope ("write")
		end

	writable (a_key: HASHABLE): BOOLEAN
		do
			Result := has_scope ("write")
		end

	removable (a_key: HASHABLE): BOOLEAN
		do
			Result := has_scope ("delete")
		end

	creatable: BOOLEAN
		do
			Result := has_scope ("write")
		end

feature {NONE} -- Implementation

	has_scope (a_name: READABLE_STRING_GENERAL): BOOLEAN
		do
			Result := scopes.has (a_name.to_string_32)
		end

	scopes: ARRAYED_SET [STRING_32]

end
