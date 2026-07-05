note
	description: "[
		Mounts RESTLY pipelines onto an EWF router.
		Provides mount_collection, mount_element, and
		mount_resource (sugar for both).
	]"

class
	RESTLY_EWF_SERVER

create
	make

feature {NONE} -- Initialization

	make (a_router: WSF_ROUTER)
			-- Initialize with `a_router'.
		do
			router := a_router
		end

feature -- Access

	router: WSF_ROUTER
			-- The EWF router.

feature -- Mounting

	mount_collection (a_template: STRING; a_storage: RESTLY_PROTOCOL [STRING, JSON_OBJECT])
			-- Mount `a_storage' as a collection endpoint at `a_template'.
		local
			l_handler: RESTLY_EWF_COLLECTION_HANDLER
		do
			create l_handler.make (a_storage)
			router.handle (a_template, l_handler, Void)
		end

	mount_element (a_template: STRING; a_storage: RESTLY_PROTOCOL [STRING, JSON_OBJECT])
			-- Mount `a_storage' as an element endpoint at `a_template'.
		local
			l_handler: RESTLY_EWF_ELEMENT_HANDLER
		do
			create l_handler.make (a_storage)
			router.handle (a_template, l_handler, Void)
		end

	mount_resource (a_template: STRING; a_storage: RESTLY_PROTOCOL [STRING, JSON_OBJECT])
			-- Sugar: mount_collection + mount_element with "/{id}".
		do
			mount_collection (a_template, a_storage)
			mount_element (a_template + "/{id}", a_storage)
		end

end
