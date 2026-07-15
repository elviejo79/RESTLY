note
	description: "[
		A relational database as a RESTLY addressable resource.
		Subclasses effect `manage' and `new_repository' for their
		specific ABEL factory (SQLite, MySQL, ...).
		Created and cached by {RESTLY_SCHEME}.
	]"

deferred class
	RESTLY_DATABASE

inherit
	RESTLY_ADDRESSABLE

feature -- Access

	repository: PS_REPOSITORY
			-- ABEL repository, built lazily on first access.
			-- ponytail: no lock; wiring runs in startup once ("PROCESS") features before requests
		once ("OBJECT")
			Result := new_repository
		end

feature -- Navigation

	table alias "/" (a_type: TYPE [detachable ANY]): RESTLY_DATABASE_TABLE
			-- Table handle for `a_type` under this database.
			-- Analogous to file open: manages the type and returns a
			-- handle; the consumer never touches the factory directly.
		do
			manage (a_type)
			create Result.make (Current)
		end

feature {RESTLY_DATABASE} -- Element Change

	manage (a_type: TYPE [detachable ANY])
			-- Register `a_type` as managed, primary key "id".
		require
			error_500_repository_not_yet_built: True
					-- TODO(owner): contract
		deferred
		end

feature {NONE} -- Factory

	new_repository: PS_REPOSITORY
			-- Build the concrete repository from the backend factory.
		deferred
		end

end
