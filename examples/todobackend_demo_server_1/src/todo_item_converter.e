note
	description: "Converter between JSON_VALUE and TODO_ITEM representations using smart serialization."

class
	TODO_ITEM_CONVERTER

inherit
	PICO_CONVERTER [JSON_VALUE, TODO_ITEM]

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize converter with smart serialization.
		local
			fac: JSON_SERIALIZATION_FACTORY
		do
			create fac
			serializer := fac.smart_serialization

			-- Set up callback for TODO_ITEM creation during deserialization
			serializer.context.deserializer_context.set_value_creation_callback (
				create {JSON_DESERIALIZER_CREATION_AGENT_CALLBACK}.make (
					agent (a_info: JSON_DESERIALIZER_CREATION_INFORMATION)
					do
						if a_info.static_type = {TODO_ITEM} then
							a_info.set_object (create {TODO_ITEM}.make_empty)
						end
					end
				)
			)
		end

feature -- Conversion

	to_store (a_r: JSON_VALUE): TODO_ITEM
			-- Convert JSON representation `a_r` to TODO_ITEM storage using smart serialization.
		local
			json_string: STRING
		do
			json_string := a_r.representation

			if attached {TODO_ITEM} serializer.from_json_string (json_string, {TODO_ITEM}) as item then
				Result := item
				-- Note: id will be set later based on storage key from PICO_TABLE
			else
				create Result.make_empty
			end
		end

	representation (a_store: TODO_ITEM): JSON_VALUE
			-- Convert TODO_ITEM `a_store` to JSON representation using smart serialization.
		local
			json_string: STRING
			parser: JSON_PARSER
			url_value: STRING
		do
			if attached serializer.to_json_string (a_store) as s then
				json_string := s
				create parser.make_with_string (json_string)
				parser.parse_content
				if attached {JSON_OBJECT} parser.parsed_json_value as json_val then
					-- Add url field computed from base_url and id
					if attached a_store.id as item_id and then not item_id.is_empty then
						url_value := base_url + item_id
						json_val.put_string (url_value, "url")
					end
					Result := json_val
				else
					create {JSON_OBJECT} Result.make_with_capacity (0)
				end
			else
				create {JSON_OBJECT} Result.make_with_capacity (0)
			end
		end

feature {NONE} -- Implementation

	serializer: JSON_SERIALIZATION
			-- Smart serialization instance for clean JSON output.

	base_url: STRING = "http://localhost:8080/todos/"
			-- Base URL for constructing todo item URLs

end
