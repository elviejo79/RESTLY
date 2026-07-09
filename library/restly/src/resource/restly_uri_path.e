note
	description: "[
		A URI_TEMPLATE restricted to relative references ("/path?query"),
		so it can only address the host its client session is bound to.
		Converts from strings: l_path := "/todos/1".
	]"

class
	RESTLY_URI_PATH

inherit
	URI_TEMPLATE
		export
			{NONE} set_template
		end

create
	make,
	make_from_uri_template

convert
	make ({READABLE_STRING_8, STRING_8}),
	template: {READABLE_STRING_8}

invariant
	key_is_relative_reference: True
			-- TODO(owner): contract
			-- suggested: template.starts_with ("/") and not template.starts_with ("//")

end
