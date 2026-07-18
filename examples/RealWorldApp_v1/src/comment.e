note
	description: "[
		RealWorld Comment on an article. Keyed by integer `id`.
		Spec: docs.realworld.show, Single Comment response.
	]"

class
	COMMENT

feature -- Access

	id: INTEGER
			-- Comment identifier.

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

	body: STRING
			-- Comment text.
		attribute
			create Result.make_empty
		end

	author: PROFILE
			-- Commenter as seen by the current viewer.
		attribute
			create Result
		end

end
