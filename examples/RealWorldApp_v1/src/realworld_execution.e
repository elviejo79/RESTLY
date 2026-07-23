note
	description: "[
		Declares the RealWorld routes; one line per OpenAPI operationId.
		Public reads get the bare pipeline; mutations get auth <| pipeline
		(authorization by composition -- see the auth ruling in
		docs/restly_ewf_design_document.org).
	]"

class
	REALWORLD_EXECUTION

inherit
	RESTLY_ROUTED_EXECUTION

	HTTP_REQUEST_METHODS
		export
			{NONE} all
		end

create
	make

feature -- Constants

	secret: STRING = "realworld-secret"
			-- HS256 signing secret (dev only).

feature {NONE} -- Router

	setup_router
		local
			gate, articles: GATEWAY
			auth, guarded: JWT_AUTH
		do
			create gate
			gate.id_parameter_name := "slug"
			gate.element_envelope := "article"
			gate.collection_envelope := "articles"
			gate.key_field := "slug"
			articles := gate <| articles_table

			create auth.make (secret)
			auth.bearer_prefix := "Token "
			guarded := auth <| articles

				-- operationId: GetArticles (public)
			Current ["/articles"] [method_get] := agent articles.items
				-- operationId: CreateArticle (token)
			Current ["/articles"] [method_post] := agent guarded.extend
				-- operationId: GetArticle (public)
			Current ["/articles/{slug}"] [method_get] := agent articles.item
				-- operationId: UpdateArticle (token; partial body -> merge)
			Current ["/articles/{slug}"] [method_put] := agent guarded.merge
				-- operationId: DeleteArticle (token)
			Current ["/articles/{slug}"] [method_delete] := agent guarded.remove
		end

feature -- Access

	articles_table: ARTICLE_STORE
			-- Shared across all request executions.
			-- once ("PROCESS"): plain `once' is once-per-thread, so each
			-- connection thread would get its own empty store.
		once ("PROCESS")
			create Result.make ("articles")
		end

end
