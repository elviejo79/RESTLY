note
	description: "[
		In-memory todobackend pipeline: stamps the key into each
		stored item as "id" so {TODOBACKEND_CONVERTER} can mint the
		element url on retrieval.
	]"

class
	TODOBACKEND_MEMORY_PIPELINE

inherit
	RESTLY_JSON_RESOURCE
		redefine
			extend, put
		end

create
	make_with_converter

feature -- REST verbs

	extend (v: JSON_OBJECT; k: STRING)
			-- <Precursor>
			-- Stamp `k` into `v` as "id" before storing.
		do
			v.replace_with_string (k, "id")
			Precursor (v, k)
		end

	put (v: JSON_OBJECT; k: STRING)
			-- <Precursor>
			-- Stamp `k` into `v` as "id" before storing.
		do
			v.replace_with_string (k, "id")
			Precursor (v, k)
		end

end
