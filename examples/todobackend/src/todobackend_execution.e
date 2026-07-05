note
	description: "Wires the RESTLY pipeline to the EWF router."

class
	TODOBACKEND_EXECUTION

inherit
	WSF_ROUTED_SKELETON_EXECUTION
		undefine
			requires_proxy
		end

	WSF_NO_PROXY_POLICY

create
	make

feature {NONE} -- Router

	setup_router
		local
			l_server: RESTLY_EWF_SERVER
		do
			create l_server.make (router)
			l_server.mount_resource ("/todos", front)
		end

feature -- Access

	front: RESTLY_JSON_PIPELINE_FRONT [INTEGER, JSON_OBJECT]
			-- Shared across all request executions.
		once
			create Result.make (create {RESTLY_HASH_TABLE [INTEGER, JSON_OBJECT]}, create {RESTLY_INT_KEY_CONVERTER}, create {TODOBACKEND_VALUE_CONVERTER})
		end

end
