note
	description: "[
		RealWorld User: the authenticated account, returned by
		login/registration/current-user endpoints. Carries the JWT.
		Spec: docs.realworld.show, User response.
	]"

class
	USER

feature -- Access

	email: STRING
			-- Login email.
		attribute
			create Result.make_empty
		end

	token: STRING
			-- JWT for the current session.
		attribute
			create Result.make_empty
		end

	username: STRING
			-- Unique handle.
		attribute
			create Result.make_empty
		end

	bio: detachable STRING
			-- Short biography; `null` in JSON when unset.

	image: detachable STRING
			-- Avatar URL; `null` in JSON when unset.

end
