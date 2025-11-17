note
	description: "Summary description for {SCHEME_CLIENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SCHEME_CLIENT[R]

inherit
	RESTLY [R]
	export
		{NONE} collection_extend
	end

feature {NONE} -- Initialization

	make (a_root: URI)
			-- Initialize scheme client with URL
		require
			valid_scheme: a_root.scheme ~ Valid_scheme
		deferred
		ensure
			base_uri_set: base_uri ~ a_root
			-- no_insertions_yet: last_inserted_key = Void
			can_connect_to_proposed_base_url: can_connect (base_uri)
		end

feature -- Attributes

	base_uri: URI
		-- The URL that identifies this scheme client

	Valid_scheme: STRING_8
			-- The scheme this client handles (e.g., "file", "http", "env")
		deferred
		end

feature -- Queries

	can_connect (a_uri: URI): BOOLEAN
			-- Can we connect to the resource at `a_uri`?
			-- Default implementation returns True.
			-- Descendants may redefine to check actual connectivity.
		do
			Result := True
		end

end
