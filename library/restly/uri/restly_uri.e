note
	description: "[
		A URI_TEMPLATE restricted to match a regex.
		Converts from strings: l_uri := "file:///home/me/dir/".
	]"

class
	RESTLY_URI

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

feature -- Uri template

	Uri_RegEx: STRING
			-- Regex a URI of this class must match.
			-- ponytail: effective (not deferred) because URI_TEMPLATE.duplicate
			-- creates `like Current' (VGCC(2) in a deferred class); a function
			-- (not constant) because constants cannot be redefined (VDRS(2)).
			-- Base accepts anything, subclasses redefine with their scheme's regex.
		do
			Result := ".*"
		end

feature -- Validation

	matches_uri_regex: BOOLEAN
			-- Does `template` match `Uri_RegEx`?
		local
			re: RX_PCRE_REGULAR_EXPRESSION
		do
			create re.make
			re.compile (Uri_RegEx)
			check re.is_compiled then -- silent failure otherwise
				re.match (template.to_string_8)
				Result := re.has_matched
			end
		end

invariant
	is_valid_uri_for_this_class: matches_uri_regex

end
