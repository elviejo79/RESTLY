note
	description: "Mapper between TODO_ITEM and STRING (JSON) for file storage"

class
	TODO_ITEM_STRING_MAPPER

inherit
	PICO_MAPPER [TODO_ITEM, STRING]
		redefine
			make
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize mapper with default storage
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

	to_store (a_item: TODO_ITEM): STRING
			-- Convert TODO_ITEM to JSON STRING for file storage
		do
			if attached serializer.to_json_string (a_item) as json_str then
				Result := json_str
			else
				create Result.make_empty
			end
		end

	representation (a_string: STRING): TODO_ITEM
			-- Convert JSON STRING from file to TODO_ITEM
		do
			if attached {TODO_ITEM} serializer.from_json_string (a_string, {TODO_ITEM}) as l_item then
				Result := l_item
			else
				create Result.make_empty
			end
		end

	merge_update (partial_data: TODO_ITEM; key: PATH_PICO)
			-- Merge partial TODO_ITEM update into stored item at key
		do
			if attached storage [key] as json_string then
				if attached {TODO_ITEM} serializer.from_json_string (json_string, {TODO_ITEM}) as original then
					original.merge (partial_data)
					storage.force (to_store (original), key)
				end
			end
		end

feature {NONE} -- Implementation

	serializer: JSON_SERIALIZATION
			-- Smart serialization instance for clean JSON output

end
