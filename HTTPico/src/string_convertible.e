note
	description: "Wrapper for STRING_8 that implements CONVERTIBLE_TO for identity conversion"
	author: "HTTPico Team"
	date: "$Date$"
	revision: "$Revision$"

class
	STRING_CONVERTIBLE

inherit
	STRING
        rename
            make as make_string,
            make_empty as make_empty_string
        end
    CONVERTIBLE_TO [STRING]
        undefine
            is_equal, copy, out
        end

create
    make_from_s,
    make_from_string,
    make_empty_string,
    make_string

convert
    make_from_s ({STRING})

feature
    to_s: STRING
        do
            create Result.make_from_string (Current)
        end

    make_from_s(a_s: STRING)
        do
            make_from_string (a_s)
        end
end
