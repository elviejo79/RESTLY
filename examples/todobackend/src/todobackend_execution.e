note
	description: "Wires the RESTLY pipeline to the EWF router."

class
	TODOBACKEND_EXECUTION

inherit
	RESTLY_EWF_SERVER

create
	make

feature {NONE} -- Router

	setup_router
		local
			l_collection: RESTLY_EWF_COLLECTION_HANDLER
			l_element: RESTLY_EWF_ELEMENT_HANDLER
		do
			create l_collection.make (front)
			map_uri_template_response ("/todos", l_collection, Void)
			create l_element.make (front)
			map_uri_template_response ("/todos/{id}", l_element, Void)
		end

feature -- Access

	front: RESTLY_JSON_PIPELINE_FRONT [INTEGER, JSON_OBJECT]
			-- Shared across all request executions.
		once
			create Result.make (create {RESTLY_HASH_TABLE [INTEGER, JSON_OBJECT]}, create {RESTLY_INT_KEY_CONVERTER}, create {TODOBACKEND_CONVERTER})
		end

end
