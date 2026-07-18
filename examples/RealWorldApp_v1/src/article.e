note
	description: "[
		RealWorld Article. Keyed by `slug` in the API.
		Wire format renders `created_at` / `updated_at` as ISO 8601
		("2016-02-18T03:22:56.637Z"); that is the converter's job.
		Spec: docs.realworld.show, Single Article response.
	]"

class
	ARTICLE

feature -- Access

	slug: STRING
			-- URL-friendly identifier ("how-to-train-your-dragon").
		attribute
			create Result.make_empty
		end

	title: STRING
			-- Article title.
		attribute
			create Result.make_empty
		end

	description: STRING
			-- Short summary.
		attribute
			create Result.make_empty
		end

	body: STRING
			-- Full text; omitted in multiple-articles responses.
		attribute
			create Result.make_empty
		end

	tag_list: LIST [STRING]
			-- Tags ("tagList" on the wire).
		attribute
			create {ARRAYED_LIST [STRING]} Result.make (0)
		end

	created_at: DATE_TIME
			-- Creation timestamp ("createdAt" on the wire).
		attribute
			create Result.make_now_utc
		end

	updated_at: DATE_TIME
			-- Last update timestamp ("updatedAt" on the wire).
		attribute
			create Result.make_now_utc
		end

	favorited: BOOLEAN
			-- Has the current viewer favorited this article?

	favorites_count: INTEGER
			-- Total favorites ("favoritesCount" on the wire).

	author: PROFILE
			-- Author as seen by the current viewer.
		attribute
			create Result
		end

end
