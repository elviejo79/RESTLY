class
    STORE_HANDLER

create
	make

feature
	make(a_router:WSF_ROUTER)
	do
		router := a_router
	end

feature
	router: WSF_ROUTER
feature
    execute(prefix:STRING; req:WSF_REQUEST; res:WSF_RESPONSE)
    do
        res.put_string("Hello World")
    end
end
