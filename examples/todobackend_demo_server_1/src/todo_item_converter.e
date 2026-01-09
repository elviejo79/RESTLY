note
	description: "Mapper between JSON_VALUE and TODO_ITEM using smart serialization with storage delegation."

class
	TODO_ITEM_CONVERTER

inherit
	PICO_MAPPER [JSON_VALUE, TODO_ITEM]
		redefine
			make
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize mapper with PICO_TABLE storage and smart serialization.
		local
			fac: JSON_SERIALIZATION_FACTORY
		do
			Precursor
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

			if attached {TODO_ITEM} serializer.from_json_string (json_string, {TODO_ITEM}) as l_item then
				Result := l_item
				-- Generate id if not provided in JSON
				if not attached Result.id or else Result.id.is_empty then
					Result.id_counter.put (Result.id_counter.item + 1)
					Result.set_id (Result.id_counter.item.out)
				end
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
					-- Add url field computed from base_url and id (always present even if id is empty/null)
					url_value := base_url
					if attached a_store.id as item_id and then not item_id.is_empty then
						url_value := base_url + item_id
					end
					json_val.put_string (url_value, "url")
					Result := json_val
				else
					create {JSON_OBJECT} Result.make_with_capacity (0)
				end
			else
				create {JSON_OBJECT} Result.make_with_capacity (0)
			end
		ensure then
			id_not_null: attached {JSON_OBJECT} Result as obj implies (attached obj.item ("id") as id_val and then not id_val.is_null)
			url_present: attached {JSON_OBJECT} Result as obj implies (attached {JSON_STRING} obj.item ("url") as url_str and then not url_str.item.is_empty)
		end

	merge_update (partial_data: JSON_VALUE; key: PATH_PICO)
			-- Merge JSON partial update into stored TODO_ITEM at key
		do
			if attached storage [key] as original then
				original.merge (to_store (partial_data))
				storage.force (original, key)
			end
		end

feature {NONE} -- Implementation

	serializer: JSON_SERIALIZATION
			-- Smart serialization instance for clean JSON output.

	base_url: STRING = "http://localhost:8080/todos/"
			-- Base URL for constructing todo item URLs

end
