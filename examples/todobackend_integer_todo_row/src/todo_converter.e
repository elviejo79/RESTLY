note
	description: "Converter stage for the todos pipeline: INTEGER keys, TODO_ROW values."

class
	TODO_CONVERTER

inherit
	RESTLY_CONVERTER [INTEGER, TODO_ROW]

create
	default_create

feature -- Conversion points

	to_key (a_raw: STRING): INTEGER
			-- <Precursor>
		do
			Result := a_raw.to_integer
		end

	raw_key (a_k: INTEGER): STRING
			-- <Precursor>
		do
			Result := a_k.out
		end

	to_json (a_r: TODO_ROW): JSON_OBJECT
			-- <Precursor>: implicit conversion via {TODO_ROW}.to_json.
		do
			Result := a_r
		end

	from_json (a_json: JSON_OBJECT): TODO_ROW
			-- <Precursor>: implicit conversion via {TODO_ROW}.make_from_json.
		do
			Result := a_json
		end

end
