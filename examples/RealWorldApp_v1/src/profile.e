note
	description: "[
		RealWorld Profile: public view of a user as seen by the
		current viewer. `following` depends on who is asking.
		Spec: docs.realworld.show, Profile response.
	]"

class
	PROFILE

feature -- Access

	username: STRING
			-- Unique handle.
		attribute
			create Result.make_empty
		end

	bio: detachable STRING
			-- Short biography; `null` in JSON when unset.

	image: detachable STRING
			-- Avatar URL; `null` in JSON when unset.

	following: BOOLEAN
			-- Does the current viewer follow this profile?

end
