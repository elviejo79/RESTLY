note
	description: "[
		Deferred execution that wires RESTLY pipelines to EWF.
		Inherit and implement setup_router using mount_resource
		(or the mount_collection / mount_element primitives, or
		map_verb for a fully explicit route table).
	]"

deferred class
	RESTLY_EWF_MOUNTING

inherit
	WSF_ROUTED_EXECUTION

	WSF_ROUTED_URI_TEMPLATE_HELPER

feature -- Mounting

	map_verb (a_resource_path: RESTLY_URI_PATH; a_methods: WSF_REQUEST_METHODS; an_action: FUNCTION [WSF_REQUEST, WSF_RESPONSE_MESSAGE])
			-- Route `a_methods' requests on `a_resource_path' to `an_action'.
		do
			map_uri_template_response (a_resource_path, create {RESTLY_EWF_CONTRACT_GUARD}.make (an_action), a_methods)
		end

	mount_resource (a_collection: RESTLY_URI_PATH; a_storage: RESTLY_PROTOCOL [STRING, JSON_OBJECT])
			-- Collection at `a_collection`, element at `a_collection + "/{id}"`.
		local
			l_handler: RESTLY_EWF_GATEWAY
			l_single_element_uri: RESTLY_URI_PATH
		do
			l_single_element_uri := a_collection.template + "/{id}"
			create l_handler.make (a_storage)

			map_verb (a_collection, router.methods_head_get, agent l_handler.get_list)
			map_verb (a_collection, router.methods_post, agent l_handler.post_new)
			map_verb (a_collection, router.methods_delete, agent l_handler.delete_all)
			map_verb (a_collection, router.methods_options, agent preflight_ok)
			map_verb (l_single_element_uri, router.methods_head_get, agent l_handler.get_one)
			map_verb (l_single_element_uri, methods_patch, agent l_handler.patch_one)
			map_verb (l_single_element_uri, router.methods_delete, agent l_handler.delete_one)
			map_verb (l_single_element_uri, router.methods_options, agent preflight_ok)
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
