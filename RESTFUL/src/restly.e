note
	description: "[
    {RESTLY}.
    A Design By Contract interpreation of the HTTP Verbs.

    * [R]epresenation. For example JSON or XHTML

    Used os the common interface for all the components that are Storage Combinators.
]"
	author: "Alejandro Garcia"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	RESTLY [R]
inherit
	RESTLY_NEW[R,PATH_OR_STRING]

feature
	has_item(data:R):BOOLEAN
	do
		Result := false
	end
end
