note
	description: "[
		A table within a {RESTLY_SQLITE} database.
		Value object: holds a strong reference to the database
		(keeps the weak-registered {RESTLY_SQLITE} alive while
		any {RESTLY_TABLE_ORIGIN} uses it).
	]"

class
	RESTLY_SQLITE_TABLE

create
	make

feature {NONE} -- Initialization

	make (a_database: RESTLY_SQLITE)
			-- Table in `a_database`.
		do
			database := a_database
		end

feature -- Access

	database: RESTLY_SQLITE
			-- Owning database (strong reference).

	repository: PS_REPOSITORY
			-- ABEL repository from the database.
		do
			Result := database.repository
		end

end
