note
	description: "[
		Concrete keycard for tests: full read/write/delete on an
		explicit key list, nothing else (writable = readable satisfies
		ground rule 9 trivially). `invalidate` breaks structural
		validity for the capability_valid violation test.
	]"

class
	TEST_CAPABILITY

inherit
	CAPABILITY

create
	make

feature {NONE} -- Initialization

	make (a_subject: READABLE_STRING_GENERAL)
		do
			subject := a_subject.to_string_8
			create permitted_keys.make (4)
			permitted_keys.compare_objects
			is_valid := True
		end

feature -- Access

	subject: STRING

	is_valid: BOOLEAN

feature -- Element change

	permit (a_key: HASHABLE)
			-- Grant full read/write/delete on `a_key`.
		do
			permitted_keys.extend (a_key)
		end

	invalidate
			-- Break structural validity (revocation stand-in).
		do
			is_valid := False
		end

feature -- Queries (the protocol's verbs, collapsed)

	readable (a_key: HASHABLE): BOOLEAN
		do
			Result := permitted_keys.has (a_key)
		end

	writable (a_key: HASHABLE): BOOLEAN
		do
			Result := readable (a_key)
		end

	removable (a_key: HASHABLE): BOOLEAN
		do
			Result := readable (a_key)
		end

	creatable: BOOLEAN
		do
			Result := True
		end

feature {NONE} -- Implementation

	permitted_keys: ARRAYED_SET [HASHABLE]

end
