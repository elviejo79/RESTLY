note
	description: "[
		Deferred execution that wires RESTLY pipelines to EWF.
		Inherit and implement setup_router using mount_resource
		(or the mount_collection / mount_element primitives, or
		map_verb for a fully explicit route table).
	]"

deferred class
	RESTLY_EWF_SERVER

inherit
	WSF_ROUTED_EXECUTION

	WSF_ROUTED_URI_TEMPLATE_HELPER

feature -- Mounting

	map_verb (a_template: STRING; a_methods: WSF_REQUEST_METHODS; an_action: FUNCTION [WSF_REQUEST, WSF_RESPONSE_MESSAGE])
			-- Route `a_methods' requests on `a_template' to `an_action'.
		do
			map_uri_template_response (a_template, create {RESTLY_EWF_ACTION_HANDLER}.make (an_action), a_methods)
		end

	mount_collection (a_template: STRING; a_storage: RESTLY_PROTOCOL [STRING, JSON_OBJECT])
			-- Mount collection verbs (GET list, POST, DELETE all) at `a_template`.
		local
			l_collection: RESTLY_EWF_COLLECTION_HANDLER
		do
			create l_collection.make (a_storage)
			map_verb (a_template, router.methods_get, agent l_collection.get_list)
			map_verb (a_template, router.methods_post, agent l_collection.post_new)
			map_verb (a_template, router.methods_delete, agent l_collection.delete_all)
			map_verb (a_template, router.methods_options, agent preflight_ok)
		end

	mount_element (a_template: STRING; a_storage: RESTLY_PROTOCOL [STRING, JSON_OBJECT])
			-- Mount element verbs (GET one, PATCH, DELETE one) at `a_template`.
		local
			l_element: RESTLY_EWF_ELEMENT_HANDLER
		do
			create l_element.make (a_storage)
			map_verb (a_template, router.methods_get, agent l_element.get_one)
			map_verb (a_template, methods_patch, agent l_element.patch_one)
			map_verb (a_template, router.methods_delete, agent l_element.delete_one)
			map_verb (a_template, router.methods_options, agent preflight_ok)
		end

	mount_resource (a_template: STRING; a_storage: RESTLY_PROTOCOL [STRING, JSON_OBJECT])
			-- Rails-resources sugar: collection at `a_template`,
			-- element at `a_template + "/{id}"`.
		do
			mount_collection (a_template, a_storage)
			mount_element (a_template + "/{id}", a_storage)
		end

feature {NONE} -- Implementation

	preflight_ok (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
			-- CORS preflight response. Mapped explicitly because {WSF_ROUTER}'s
			-- automatic OPTIONS reply lacks "Connection: close" (~5s keep-alive stall).
		do
			Result := {WSF_JSON_RESPONSE}.no_content
		end

	methods_patch: WSF_REQUEST_METHODS
			-- Method set containing only PATCH ({WSF_ROUTER} has no convenience query for it).
		do
			create Result
			Result.enable_patch
		end

end
