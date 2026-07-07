note
	description: "Exposes status_from_tag for testing."

class
	TEST_TAG_PARSER_HELPER

inherit
	RESTLY_EWF_ACTION_HANDLER
		export
			{ANY} status_from_tag
		end

create
	make

end
