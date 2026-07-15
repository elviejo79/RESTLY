note
	description: "[
		A SQLite database file as a RESTLY addressable resource.
		Owns the shared ABEL factory and lazily-built repository for its file.
		Created and cached by {RESTLY_SCHEME}.
	]"

class
	RESTLY_SQLITE

inherit
	RESTLY_ADDRESSABLE

create
	make

feature {NONE} -- Initialization

	make (a_file: READABLE_STRING_GENERAL)
			-- Database backed by file `a_file`.
		do
			create factory.make
			factory.set_database (a_file.to_string_8)
		end

feature {RESTLY_SQLITE} -- Declaration

	declare (a_type: TYPE [detachable ANY])
			-- Register `a_type` as managed, primary key "id".
		require
			error_500_repository_not_yet_built: True
					-- TODO(owner): contract
		do
			factory.manage (a_type, "id")
		end

feature -- Access

	repository: PS_REPOSITORY
			-- ABEL repository, built lazily on first access.
			-- ponytail: no lock; wiring runs in startup once ("PROCESS") features before requests
		do
			if attached internal_repository as l_repo then
				Result := l_repo
			else
				internal_repository := factory.new_repository
				check built: attached internal_repository as l_repo then
					Result := l_repo
				end
			end
		end

feature -- Navigation

	table alias "/" (a_type: TYPE [detachable ANY]): RESTLY_SQLITE_TABLE
			-- Table handle for `a_type` under this database.
		do
			declare (a_type)
			create Result.make (Current)
		end

feature {NONE} -- Implementation

	factory: PS_SQLITE_RELATIONAL_REPOSITORY_FACTORY
			-- ABEL factory; accumulates `declare` calls until `repository` freezes it.

	internal_repository: detachable PS_REPOSITORY
			-- Cached after first build.

end
