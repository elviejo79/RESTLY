note
	description: "Summary description for {STORE_ROUTER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STORE_ROUTER

inherit
	WSF_ROUTER

create
	make_with

feature
	make_with (a_prefix: URL_PATH; a_store: REST [ANY])
		do
			prefix := a_prefix
			store := a_store

		end

feature --fields
	prefix: URL_PATH
	store: REST [ANY]

feature
	setup_router (router: WSF_ROUTER)
		local
			handler: STORE_HANDLER
		do
			create handler.make (router)
			router.handle (prefix.out, handler, router.methods_GET)
		end

end
