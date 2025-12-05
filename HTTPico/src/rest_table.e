note
	description: "An implementation of HASH_TABLE that has REST INTERFACE {REST_TABLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REST_TABLE [R -> attached ANY]

inherit
	HASH_TABLE [R, PATH_HTTPICO]
		rename
			extend as hash_extend,
			item as hash_item,
			at as hash_at
		end

	HTTPICO_VERBS [R]
		undefine
			is_equal, copy, has_item
		end
create
	make

feature
	at alias "@", item alias "[]" (key: PATH_HTTPICO): R assign force
		do
			check attached hash_item(key) as value then
				Result := value
			end
		end

	last_inserted_key: PATH_HTTPICO
		attribute
			create Result.make_from_string ("")
		end

      extend(data:R; key: PATH_HTTPICO)
      do
         check attached key as l_key then
            last_inserted_key := l_key
            hash_extend(data, l_key)
         end
      end
end
