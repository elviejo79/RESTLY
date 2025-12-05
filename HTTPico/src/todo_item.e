note
	description: "Todo item with custom equality based only on text and completed fields"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TODO_ITEM

inherit
	JSON_OBJECT
		undefine
			is_equal
		end
	CONVERTIBLE_TO[STRING]
		undefine
			is_equal
		end
create
	make,
	make_empty,
	make_from_string,
	make_from_s,
	make_from_separate

convert
	to_s: {STRING},
	make_from_S({STRING})

feature -- CONVERTIBLE_TO features

	to_s: STRING
			-- Convert to STRING representation (JSON)
		do
			Result := representation
		end

	make_from_s(a_s:STRING)
	do
		make_from_string(a_s)
	end

feature -- Comparison

	is_equal (other: TODO_ITEM): BOOLEAN
			-- Is `other' equal to current TODO_ITEM?
			-- Only compares id, text, and completed fields, ignoring modified-at
		do
			Result := item ("id") ~ other.item ("id") and
			          item ("text") ~ other.item ("text") and
			          item ("completed") ~ other.item ("completed")
		end

end
