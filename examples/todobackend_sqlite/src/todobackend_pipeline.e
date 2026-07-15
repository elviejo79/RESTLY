note
	description: "[
		The todobackend crossing, named: JSON web side
		[STRING, JSON_OBJECT], relational store side
		[INTEGER, TODO_ROW].
		Supplies its own converters — they are determined by the
		types; only the backing store is a genuine parameter.
	]"

class
	TODOBACKEND_PIPELINE

inherit
	RESTLY_JSON_PIPELINE_FRONT [INTEGER, TODO_ROW]
		rename
			make as make_with_converters
		end

create
	make

feature {NONE} -- Initialization

	make (a_store: RESTLY_PROTOCOL [INTEGER, TODO_ROW])
			-- Front for `a_store` with the todobackend converters.
		do
			make_with_converters (a_store,
				create {RESTLY_KEY_CONVERTER_STRING_INTEGER},
				create {TODOBACKEND_CONVERTER_JSON_OBJECT_TODO_ROW})
		end

end
