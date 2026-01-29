note
	description: "Decorator that adds URL field to TODO_ITEM JSON representations"

class
	TODO_JSON_DECORATOR

inherit
	PICO_CONVERTER_JSON[TODO_ITEM]
		redefine
			item
		end

create
	make_with_backend

feature -- Initialization

	make_with_backend (a_backend: like backend; a_base_url: STRING)
		do
			backend := a_backend
			base_url := a_base_url
			create last_modified_key.make_from_string ("")
		end

feature -- State

	base_url: STRING

	backend: PICO_VERBS[TODO_ITEM]

feature -- Queries

	item alias "/" (a_key: PATH): JSON_OBJECT assign force
		do
			Result := Precursor (a_key)
			Result.put_string (base_url + "/" + a_key.name.to_string_8, "url")
		end


end
