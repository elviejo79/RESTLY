note
	description: "[
		The Authorization header as it arrived: untrusted text,
		possibly absent. The only thing outside the trust boundary
		that the codec ever touches.
	]"

class
	RAW_CREDENTIAL

create
	make,
	make_absent

feature {NONE} -- Initialization

	make (a_text: READABLE_STRING_8)
		do
			text := a_text.to_string_8
			is_present := True
		end

	make_absent
			-- No Authorization header at all.
		do
			create text.make_empty
		end

feature -- Access

	text: STRING_8

	is_present: BOOLEAN

end
