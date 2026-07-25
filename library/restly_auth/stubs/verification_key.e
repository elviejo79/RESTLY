note
	description: "HS256 shared secret, wrapped so signature checks never pass bare strings around."

class
	VERIFICATION_KEY

create
	make

feature {NONE} -- Initialization

	make (a_secret: READABLE_STRING_8)
		do
			secret := a_secret.to_string_8
		end

feature -- Access

	secret: STRING_8

end
