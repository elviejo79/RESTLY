note
	description: "[
		Declares the RealWorld routes; one line per OpenAPI operationId.
		Articles: gate <| store, auth by composition.
		Users: USER_STORE (real store) + USER_HANDLER (adapter).
		Commands return PRG 303 (CQS); queries return 200.
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

	jwt_codec: JWT_CODEC
		once ("PROCESS")
			create Result.make (secret, "realworld-issuer", "realworld-audience")
		end

feature {NONE} -- Router

	setup_router
		local
			gate: GATEWAY
			auth: AUTH_BOUNDARY
			guarded: AUTH_BOUNDARY
			articles: GATEWAY
			uh: USER_HANDLER
		do
				-- Auth guard (shared)
			create auth.make (jwt_codec)
			auth.bearer_prefix := "Token "

				-- Article pipelines
			create gate
			gate.id_parameter_name := "slug"
			articles := gate <| articles_table
			guarded := auth <| articles

			Current ["/articles"] [method_get] := agent articles.items				-- operationId: GetArticles (public)
			Current ["/articles"] [method_post] := agent guarded.extend				-- operationId: CreateArticle (token)
			Current ["/articles/{slug}"] [method_get] := agent articles.item			-- operationId: GetArticle (public)
			Current ["/articles/{slug}"] [method_put] := agent guarded.merge			-- operationId: UpdateArticle (token)
			Current ["/articles/{slug}"] [method_delete] := agent guarded.remove		-- operationId: DeleteArticle (token)

				-- User store + handler
			uh := (create {USER_HANDLER}.make (auth)) <| users_table

			Current ["/users"] [method_post] := agent uh.register				-- operationId: CreateUser (public)
			Current ["/users/login"] [method_post] := agent uh.login			-- operationId: Login (public)
			Current ["/users/{id}"] [method_get] := agent uh.user_by_id			-- PRG target for register + login
			Current ["/user"] [method_get] := agent uh.current_user				-- operationId: GetCurrentUser (token)
			Current ["/user"] [method_put] := agent uh.update_user				-- operationId: UpdateCurrentUser (token)
		end

feature -- Access

	articles_table: ARTICLE_STORE
		once ("PROCESS")
			create Result.make ("articles")
		end

	users_table: USER_STORE
		once ("PROCESS")
			create Result.make ("users")
			Result.secret := secret
		end

end
