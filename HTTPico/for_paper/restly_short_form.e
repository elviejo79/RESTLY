note
	description: "[
		    {RESTLY}.
		    A Design By Contract interpreation of the HTTP Verbs.
		
		    * [R]epresenation. For example JSON or XHTML
		
		    Used os the common interface for all the components that are Storage Combinators.
	]"
	author: "Alejandro Garcia"
	date: "$Date$"
	revision: "$Revision$"

deferred class interface
	RESTLY [R -> ]

feature -- Commands aka Http unsafe verbs

	collection_extend (data: R)
			-- equivalent to http POST
			-- Submits data; may change state or cause side effects
		require
			when_appending_data_should_not_stored: not has_item (data)
		ensure
			data_stored_or_throw_510_not_extended: attached item (last_inserted_key)

	force (data: R; key: URL_PATH)
			-- Equivalent to http PUT
			-- Replaces the resource's representation with the request content.
			-- if key didn't exist it stil inserts it
		ensure then
			data_stored_or_throw_507_insuficient_storage: attached item (key)

	remove (key: URL_PATH)
			-- Equivalent to http DELETE
			-- Removes the specified resource.
		ensure
			truly_eliminated_or_throw_500_internal_server_error: not has_key (key)
	
feature -- Queries aka Http safe verbs

	has_key (key: URL_PATH): BOOLEAN
			-- Equivalent to http HEAD
			-- Same as GET but without a response body

	item alias "[]" (key: URL_PATH): R assign force
			-- Equivalent to http GET
			-- Requests a resource representation; retrieves data only.
		require else
			requested_a_known_key_or_throw_404_not_found: has_key (key)
		ensure
			must_return_item_or_throw_500_internal_server_error: Result /= Void
	
feature -- helpers

	has_item (data: R): BOOLEAN

	last_inserted_key: URL_PATH
			-- There is NO equivalent for this in http protocol.
			-- but is necessary to keep the Command / Query Separation principle in Eiffel
	
end -- class RESTLY

