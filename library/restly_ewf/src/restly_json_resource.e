note
	description: "[
		Ready-to-mount JSON resource: a pipeline front over its own
		in-memory RESTLY_HASH_TABLE with STRING keys and identity
		converters on both axes. All mappings default to identity
		(the MappingStore default configuration); inject a store or
		a value converter to override.
	]"

class
	RESTLY_JSON_RESOURCE

inherit
	RESTLY_JSON_PIPELINE_FRONT [STRING, JSON_OBJECT]
		redefine
			default_create
		end

create
	default_create, make_with_store, make_with_converter, make

feature {NONE} -- Initialization

	default_create
			-- In-memory store, identity converters.
		do
			make_with_store (create {RESTLY_HASH_TABLE [STRING, JSON_OBJECT]}.with_object_equality)
		end

	make_with_store (a_store: RESTLY_PROTOCOL [STRING, JSON_OBJECT])
			-- Wire `a_store` with identity converters.
			-- Hash-table stores need object equality for STRING keys.
		do
			make (a_store, create {RESTLY_IDENTITY_KEY_CONVERTER [STRING]}, create {RESTLY_IDENTITY_CONVERTER [JSON_OBJECT]})
		end

	make_with_converter (a_converter: RESTLY_CONVERTER [JSON_OBJECT, JSON_OBJECT])
			-- In-memory store, identity keys, `a_converter` for values.
		do
			make (create {RESTLY_HASH_TABLE [STRING, JSON_OBJECT]}.with_object_equality, create {RESTLY_IDENTITY_KEY_CONVERTER [STRING]}, a_converter)
		end

end
