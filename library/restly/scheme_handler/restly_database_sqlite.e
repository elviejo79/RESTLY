note
	description: "SQLite backend for {RESTLY_DATABASE}."

class
	RESTLY_DATABASE_SQLITE

inherit
	RESTLY_DATABASE

create
	make

feature {NONE} -- Initialization

	make (a_url: RESTLY_SQLITE_URI)
			-- Database backed by the SQLite file named in `a_url`,
			-- e.g. "sqlite:///home/me/db.sqlite/".
		do
			base_url := a_url
			create factory.make
			factory.set_database (a_url.file_name)
		end

feature {RESTLY_DATABASE} -- Element Change

	manage (a_type: TYPE [detachable ANY])
			-- <Precursor>
		do
			factory.manage (a_type, "id")
		end

feature {NONE} -- Factory

	new_repository: PS_REPOSITORY
			-- <Precursor>
		do
			Result := factory.new_repository
		end

	factory: PS_SQLITE_RELATIONAL_REPOSITORY_FACTORY
			-- ABEL SQLite factory; accumulates `manage` calls until `repository` freezes it.

end
