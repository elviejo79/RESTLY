note
	description: "[
		Mixin: JSON body parsing and envelope wrapping.
		Shared by GATEWAY and any handler that reads/writes
		JSON request/response bodies using RESTLY_WIRE_SCHEMA
		envelope conventions.
	]"

deferred class
	RESTLY_JSON_BODY

inherit
	RESTLY_WIRE_SCHEMA

feature {NONE} -- Body parsing

	parse_body (req: WSF_REQUEST): JSON_OBJECT
			-- Parse JSON body, unwrap `element_envelope` if set.
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
			if attached element_envelope as l_name and then attached {JSON_OBJECT} Result [l_name] as l_inner then
				Result := l_inner
			end
		end

feature {NONE} -- Response wrapping

	wrapped (a_value: JSON_OBJECT): JSON_OBJECT
			-- `a_value` wrapped in `element_envelope` if set,
			-- or `a_value` itself if no envelope.
		do
			if attached element_envelope as l_name then
				create Result.make_with_capacity (1)
				Result.put (a_value, l_name)
			else
				Result := a_value
			end
		end

end
