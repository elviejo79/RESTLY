note
	description: "Summary description for {ENV_SCHEME}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENV_SCHEME

inherit
	PICO_SCHEME_HANDLER [STRING]
		undefine
			has_item
		end

	EXECUTION_ENVIRONMENT
		rename
			item as env_item,
			starting_environment as keys
		export
			{none} all
		end

create
	make

feature {NONE} -- Initialization

	make (a_root: URI)
			-- Initialize with URL
		do
			base_uri := a_root
		end

feature -- Attributes

	Valid_scheme: ARRAY[STRING_8]
		once
			Result := << "env" >>
			Result.compare_objects
		end
			-- This client handles env:// URLs
feature -- Queries aka Http safe verbs

	has_key (key: PATH_PICO): BOOLEAN
		do
			Result := attached env_item (key.name)
		end

	item alias "[]" (key: PATH_PICO): STRING assign force
		do
			check attached env_item (key.name) as l_item then
				Result := l_item
			end
		end

feature -- Commands aka Http unsafe verbs

	force (data: STRING; key: PATH_PICO)
			-- Equivalent to http PUT
			-- Replaces the resource's representation with the request content.
			-- if key didn't exist it stil inserts it
		do
			check not data.is_empty then
				put (data, key.name)
				last_inserted_key := key
			end
		end

feature {NONE}
	collection_extend (data: STRING)
			-- Not supported for environment variables
		do
		ensure then
			command_not_valid_for_env_variables: false
		end

	has_item (data: STRING): BOOLEAN
			-- Not supported for environment variables
		do
		ensure then
			command_not_valid_for_env_variables: false
		end

	remove (key: PATH_PICO)
			-- Not supported for environment variables
		do
		ensure then
			command_not_valid_for_env_variables: false
		end

feature -- helpers
	last_inserted_key: detachable PATH_PICO
			-- There is NO equivalent for this in http protocol.
			-- but is necessary to keep the Command / Query Separation principle in Eiffel

end
