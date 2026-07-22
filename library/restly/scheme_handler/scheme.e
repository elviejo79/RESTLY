note
	description: "[
		Universal scheme handlers with a process-wide weak resource registry.
		All features are instance-free (ensure class); call sites use
		{RESTLY_SCHEME}.sqlite (...) without create.
		ponytail: no locking (wiring runs in startup once before requests);
		registry key is the string as given, no path canonicalization;
		add normalization when two spellings must alias.
	]"

class
	SCHEME

feature -- Scheme handlers

	sqlite (a_file: READABLE_STRING_GENERAL): RESTLY_DATABASE_SQLITE
			-- SQLite database for `a_file`; same file yields same instance.
		local
			l_uri: RESTLY_SQLITE_URI
			l_ref: WEAK_REFERENCE [RESTLY_RESOURCE]
		do
			create l_uri.make ("sqlite://" + a_file.to_string_8 + "/")
			if
				attached resources.item (l_uri.template) as l_existing
				and then attached l_existing.item as l_item
				and then attached {RESTLY_DATABASE_SQLITE} l_item as l_sqlite
			then
				Result := l_sqlite
			else
				create Result.make (l_uri)
				create l_ref.put (Result)
				resources.force (l_ref, Result.base_url.template)
			end
		ensure
			instance_free: class
		end

	sqlite_graph (a_file: READABLE_STRING_GENERAL): RESTLY_DATABASE_SQLITE_GRAPH
			-- Object-graph SQLite database for `a_file`; same file yields same instance.
		local
			l_uri: RESTLY_SQLITE_GRAPH_URI
			l_ref: WEAK_REFERENCE [RESTLY_RESOURCE]
		do
			create l_uri.make ("sqlite+graph://" + a_file.to_string_8 + "/")
			if
				attached resources.item (l_uri.template) as l_existing
				and then attached l_existing.item as l_item
				and then attached {RESTLY_DATABASE_SQLITE_GRAPH} l_item as l_graph
			then
				Result := l_graph
			else
				create Result.make (l_uri)
				create l_ref.put (Result)
				resources.force (l_ref, Result.base_url.template)
			end
		ensure
			instance_free: class
		end

	file (a_directory: READABLE_STRING_GENERAL): RESTLY_DIRECTORY
			-- Filesystem directory for `a_directory`; same path yields same instance.
		local
			l_uri: RESTLY_FILE_URI
			l_ref: WEAK_REFERENCE [RESTLY_RESOURCE]
		do
			create l_uri.make ("file://" + a_directory.to_string_8 + "/")
			if
				attached resources.item (l_uri.template) as l_existing
				and then attached l_existing.item as l_item
				and then attached {RESTLY_DIRECTORY} l_item as l_dir
			then
				Result := l_dir
			else
				create Result.make (l_uri)
				create l_ref.put (Result)
				resources.force (l_ref, Result.base_url.template)
			end
		ensure
			instance_free: class
		end

	http (a_url: READABLE_STRING_GENERAL): RESTLY_HTTP_CLIENT
			-- HTTP client for `a_url`; same URL yields same instance.
		local
			l_uri: RESTLY_HTTP_URI
			l_ref: WEAK_REFERENCE [RESTLY_RESOURCE]
		do
			create l_uri.make (a_url.to_string_8)
			if
				attached resources.item (l_uri.template) as l_existing
				and then attached l_existing.item as l_item
				and then attached {RESTLY_HTTP_CLIENT} l_item as l_client
			then
				Result := l_client
			else
				create Result.make (l_uri)
				create l_ref.put (Result)
				resources.force (l_ref, Result.base_url.template)
			end
		ensure
			instance_free: class
		end

feature {NONE} -- Registry

	resources: STRING_TABLE [WEAK_REFERENCE [RESTLY_RESOURCE]]
			-- Process-wide weak cache keyed by canonical URL.
			-- ponytail: no eviction; dead weak refs accumulate until key is reused
		once ("PROCESS")
			create Result.make (4)
		ensure
			instance_free: class
		end

end
