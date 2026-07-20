note
	description: "[
		Route table facade with bracket-assigner syntax:
		routes ["/todos"] := a_handler
		Registering a handler maps the nine verb/URI pairs of a REST
		collection (collection GET/POST/DELETE/OPTIONS, element
		GET/HEAD/PATCH/DELETE/OPTIONS) onto the execution's router.
	]"

class
	RESTLY_ROUTES

create
	make

feature {NONE} -- Initialization

	make (an_execution: RESTLY_ROUTED_EXECUTION)
			-- Route table mapping onto `an_execution`'s router.
		do
			execution := an_execution
			create table.with_object_equality
		end

feature -- Access

	item alias "[]" (a_uri: READABLE_STRING_8): GATEWAY assign put
			-- Handler mounted at `a_uri`.
		do
			Result := table [a_uri.to_string_8]
		end

feature -- Element change

	put (a_handler: GATEWAY; a_uri: READABLE_STRING_8)
			-- Mount `a_handler` at collection `a_uri`
			-- (element URI: `a_uri` + "/{id}").
		local
			l_collection_uri, l_element_uri: RESTLY_URI_PATH
			l_router: WSF_ROUTER
		do
			l_collection_uri := a_uri.to_string_8
			l_element_uri := a_uri + "/{" + a_handler.id_parameter_name + "}"
			l_router := execution.router

			execution.map_verb (l_router.methods_head_get, l_collection_uri, agent a_handler.items)
			execution.map_verb (l_router.methods_post,     l_collection_uri, agent a_handler.extend)
			execution.map_verb (l_router.methods_delete,   l_collection_uri, agent a_handler.wipe_out)
			execution.map_verb (l_router.methods_options,  l_collection_uri, agent a_handler.preflight_ok)
			execution.map_verb (l_router.methods_get,      l_element_uri, agent a_handler.item)
			execution.map_verb (l_router.methods_head,     l_element_uri, agent a_handler.head)
			execution.map_verb (methods_patch,             l_element_uri, agent a_handler.merge)
			execution.map_verb (l_router.methods_delete,   l_element_uri, agent a_handler.remove)
			execution.map_verb (l_router.methods_options,  l_element_uri, agent a_handler.preflight_ok)

			table.extend (a_handler, a_uri.to_string_8)
		end

feature {NONE} -- Implementation

	execution: RESTLY_ROUTED_EXECUTION
			-- Execution whose router receives the mappings.

	table: V_HASH_TABLE [STRING, GATEWAY]
			-- Mounted handlers by collection URI.

	methods_patch: WSF_REQUEST_METHODS
			-- Method set containing only PATCH ({WSF_ROUTER} has no convenience query for it).
		do
			create Result
			Result.enable_patch
		end

end
