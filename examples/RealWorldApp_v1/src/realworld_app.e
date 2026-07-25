note
	description: "[
		Root class: smoke-checks that every domain object creates
		with sane defaults. Grows into the RealWorld server.
	]"

class
	REALWORLD_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Create one of each domain object.
		local
			user: USER
			profile: PROFILE
			article: ARTICLE
			comment: COMMENT
			server: REALWORLD_SERVER
		do
			create user
			create profile
			create article
			create comment
			check
				fresh_article_has_no_tags: article.tag_list.is_empty
				fresh_article_not_favorited: not article.favorited
				fresh_comment_has_author: comment.author.username.is_empty
				fresh_profile_not_following: not profile.following
				fresh_user_without_bio: user.bio = Void
			end
			smoke_check_jwt_auth
			io.put_string ("RealWorld domain objects OK%N")
			print_dev_token
			create server.make
		end

	print_dev_token
			-- Print a token curl can pass as: Authorization: Token <tok>
		local
			jws: JWS
		do
			create jws.make_with_json_payload ("{%"sub%":%"1%"}")
			jws.set_algorithm_to_hs256
			io.put_string ("dev token: " + jws.encoded_string ({REALWORLD_EXECUTION}.secret) + "%N")
		end

	smoke_check_jwt_auth
			-- Token round trip and pipeline wiring for the auth combinator.
		local
			auth, wired: JWT_AUTH
			jws: JWS
			tok: STRING
		do
			create auth.make ("realworld-secret")
			create jws.make_with_json_payload ("{%"sub%":%"1%"}")
			jws.set_algorithm_to_hs256
			tok := jws.encoded_string ("realworld-secret")
			wired := auth <| (create {GATEWAY}) <| create {RESOURCE_HASH_TABLE [STRING, JSON_OBJECT]}.make ("smoke")
			check
				valid_token_accepted: auth.is_valid_token (tok)
				tampered_token_rejected: not auth.is_valid_token (tok + "x")
				wrong_secret_rejected: not (create {JWT_AUTH}.make ("other")).is_valid_token (tok)
				auth_backed_by_gateway: attached {GATEWAY} wired.back
			end
		end

end
