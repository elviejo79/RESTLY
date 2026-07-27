note
	description: "[
		Mixin: JSON request body parsing.
		Envelope wrapping is a wire concern and lives in the
		codec stage of the pipeline, not here.
	]"

deferred class
	RESTLY_JSON_BODY

feature {NONE} -- Body parsing

	parse_body (req: WSF_REQUEST): JSON_OBJECT
			-- Parse JSON body.
		local
			l_input: STRING
			l_parser: JSON_PARSER
		do
			create l_input.make_empty
			req.read_input_data_into (l_input)
			create l_parser.make_with_string (l_input)
			l_parser.parse_content
			if l_parser.is_valid and then attached l_parser.parsed_json_object as l_obj then
				Result := l_obj
			else
				create Result.make_with_capacity (0)
			end
		end

end
