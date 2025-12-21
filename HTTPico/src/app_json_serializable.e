note
	description: "[
		Deferred class providing JSON serialization and deserialization capabilities.
		Descendants must implement `json_sed` and `make_empty`.
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	APP_JSON_SERIALIZABLE

feature {NONE} -- Implementation

	empty_factory: like Current
			-- Create a new empty instance for deserialization
		deferred
		end

feature -- JSON serialization/deserialization

	json_sed: JSON_SERIALIZATION
			-- JSON serialization instance configured for this class
		local
			fac: JSON_SERIALIZATION_FACTORY
		once
			Result := fac.smart_serialization
			Result.context.deserializer_context.set_value_creation_callback (create {JSON_DESERIALIZER_CREATION_AGENT_CALLBACK}.make (
				agent (a_info: JSON_DESERIALIZER_CREATION_INFORMATION)
				do
					if a_info.static_type = {like Current} then
						a_info.set_object (empty_factory)
					end
				end
			))
		end


	to_json: JSON_VALUE
			-- JSON object representation of current object
		do
			Result := json_sed.to_json (Current)
		end

	to_json_string: STRING
			-- JSON string representation of current object
		do
			Result := json_sed.to_json_string (Current)
		end

	from_json (a_json: JSON_VALUE): like Current
			-- Create object from JSON value
		do
			check attached {like Current} json_sed.from_json (a_json, {like Current}) as temp then
				Result := temp
			end
		end

	from_json_string (a_json_string: STRING): like Current
			-- Create object from JSON string
		do
			check attached {like Current} json_sed.from_json_string (a_json_string, {like Current}) as temp then
				Result := temp
			end
		end

end
