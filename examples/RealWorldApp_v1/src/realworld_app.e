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
			smoke_check_cache
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
			l_codec: JWT_CODEC
			auth: AUTH_BOUNDARY
			jws: JWS
			tok: STRING
			l_time: DATE_TIME
		do
			create l_codec.make ("realworld-secret", "realworld-issuer", "realworld-audience")
			create auth.make (l_codec)
			create jws
			jws.claimset.set_subject ({STRING_32} "1")
			jws.claimset.set_issuer ("realworld-issuer")
			jws.claimset.set_audience ("realworld-audience")
			jws.claimset.set_claim ("scope", "read write delete")
			jws.claimset.set_expiration_time (create {DATE_TIME}.make_from_epoch (2000000000))
			jws.claimset.set_not_before_time (create {DATE_TIME}.make_from_epoch (1700000000))
			tok := jws.encoded_string ("realworld-secret")
			create l_time.make_now_utc
				-- TODO(auth): pipeline-wiring check retired with GATEWAY; restore once an
				-- auth combinator exists over the container protocol.
				-- wired := auth <| (create {GATEWAY}) <| create {RESOURCE_HASH_TABLE [STRING, JSON_OBJECT]}.make ("smoke")
			check
				valid_token_accepted: l_codec.authenticated (tok, l_time)
				tampered_token_rejected: not l_codec.authenticated (tok + "x", l_time)
			end
		end

	smoke_check_cache
			-- Static factory + `<|` wiring; write-through, hit path,
			-- and read-through miss path.
		local
			cache: CACHE [STRING, JSON_OBJECT]
			slow: RESOURCE_HASH_TABLE [STRING, JSON_OBJECT]
			written, behind: JSON_OBJECT
		do
			create slow.make ("slow")
			cache := {CACHE [STRING, JSON_OBJECT]}.fronted_by (
				create {RESOURCE_HASH_TABLE [STRING, JSON_OBJECT]}.make ("fast")) <| slow
			create written.make
			cache.extend (written, "a")
			create behind.make
			slow.extend (behind, "b")
			check
				write_readable: cache.has_key ("a") and then cache.item ("a") = written
				miss_falls_through: cache.has_key ("b") and then cache.item ("b") = behind
				miss_populated_front: cache.front.has_key ("b")
			end
		end

end
