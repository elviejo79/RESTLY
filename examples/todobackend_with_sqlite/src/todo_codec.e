note
	description: "Converter stage for the todos pipeline: INTEGER keys, TODO_ROW values."

class
	TODO_CODEC

inherit
	CONVERTER [STRING,JSON_OBJECT,INTEGER, TODO_ROW]
		redefine
			default_create
		end

	RESTLY_WIRE_SCHEMA
		redefine
			default_create
		end

create
	default_create

feature {NONE} -- Initialization

	default_create
		do
			url_field := "url"
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
			-- <Precursor>: implicit conversion via {TODO_ROW}.to_json.
		do
			Result := a_value
		end

	storage_value (a_value: JSON_OBJECT): TODO_ROW
			-- <Precursor>: implicit conversion via {TODO_ROW}.make_from_json.
		do
			Result := a_value
		end

end
