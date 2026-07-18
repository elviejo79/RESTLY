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
			io.put_string ("RealWorld domain objects OK%N")
		end

end
