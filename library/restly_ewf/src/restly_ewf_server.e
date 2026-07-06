note
	description: "[
		Deferred execution that wires RESTLY pipelines to EWF.
		Inherit and implement setup_router using mount_resource
		(or the mount_collection / mount_element primitives).
	]"

deferred class
	RESTLY_EWF_SERVER

inherit
	WSF_ROUTED_EXECUTION

	WSF_ROUTED_URI_TEMPLATE_HELPER

feature -- Mounting

	mount_collection (a_template: STRING; a_storage: RESTLY_PROTOCOL [STRING, JSON_OBJECT])
			-- Mount collection verbs (GET list, POST, DELETE all) at `a_template`.
		require
			template_not_empty: True -- TODO(owner): contract
		do
			map_uri_template_response (a_template, create {RESTLY_EWF_COLLECTION_HANDLER}.make (a_storage), Void)
		end

	mount_element (a_template: STRING; a_storage: RESTLY_PROTOCOL [STRING, JSON_OBJECT])
			-- Mount element verbs (GET one, PATCH, DELETE one) at `a_template`.
		require
			template_not_empty: True -- TODO(owner): contract
		do
			map_uri_template_response (a_template, create {RESTLY_EWF_ELEMENT_HANDLER}.make (a_storage), Void)
		end

	mount_resource (a_template: STRING; a_storage: RESTLY_PROTOCOL [STRING, JSON_OBJECT])
			-- Rails-resources sugar: collection at `a_template`,
			-- element at `a_template + "/{id}"`.
		require
			template_not_empty: True -- TODO(owner): contract
		do
			mount_collection (a_template, a_storage)
			mount_element (a_template + "/{id}", a_storage)
		end

end
