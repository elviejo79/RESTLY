note
	description: "[
		Handle into a {RESTLY_DATABASE}.
		{RESTLY_SCHEME} locates the resource, `/' mints this handle,
		{RESTLY_TABLE_ORIGIN} holds only the handle — same shape as
		a file descriptor: open returns a handle, read uses it, the
		process never touches the inode directly.

		The strong reference keeps the weak-registered {RESTLY_DATABASE}
		alive; `repository' is deferred until the first verb call, so
		all `declare' calls complete before the factory freezes.
	]"

class
	RESTLY_DATABASE_TABLE

create
	make

feature {NONE} -- Initialization

	make (a_database: RESTLY_DATABASE)
			-- Table in `a_database`.
		do
			database := a_database
		end

feature -- Access

	database: RESTLY_DATABASE
			-- Owning database (strong reference).

	repository: PS_REPOSITORY
			-- ABEL repository from the database.
		do
			Result := database.repository
		end

end
