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
		local
			l_file: STRING
		do
			base_url := a_url
			l_file := a_url.template.to_string_8.substring (10, a_url.template.count)
			if l_file.count > 1 and then l_file.ends_with ("/") then
				l_file.remove_tail (1)
			end
			create factory.make
			factory.set_database (l_file)
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
