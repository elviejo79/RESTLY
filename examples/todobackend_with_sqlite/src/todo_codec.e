note
	description: "Converter stage for the todos pipeline: INTEGER keys, TODO_ROW values."

class
	TODO_CODEC

inherit
	CONVERTER [STRING,JSON_OBJECT,INTEGER, TODO_ROW]
		redefine
			default_create
		end

create
	default_create

feature {NONE} -- Initialization

	default_create
		do
			create base_url.make_empty
		end

feature -- Configuration

	base_url: STRING assign set_base_url
			-- Prefix for the derived `url` field, set at configuration time.

	set_base_url (a_url: STRING)
		do
			base_url := a_url
		end

feature -- Conversion points

	storage_key (a_key: STRING): INTEGER
			-- <Precursor>
		do
			Result := a_key.to_integer
		end

	representation_key (a_key: INTEGER): STRING
			-- <Precursor>
		do
			Result := a_key.out
		end

	representation (a_value: TODO_ROW): JSON_OBJECT
			-- <Precursor>: {TODO_ROW}.to_json plus the derived `url`.
		do
			Result := a_value
			Result.put (create {JSON_STRING}.make_from_string (base_url + a_value.id.out), "url")
		end

	storage_value (a_value: JSON_OBJECT): TODO_ROW
			-- <Precursor>: implicit conversion via {TODO_ROW}.make_from_json,
			-- which ignores the derived `url` field on the way in.
		do
			Result := a_value
		end

end
