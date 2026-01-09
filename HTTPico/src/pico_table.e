note
	description: "An implementation of HASH_TABLE that has REST INTERFACE {PICO_TABLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PICO_TABLE [R -> attached ANY ]

inherit
HASH_TABLE [R, PATH_PICO]
		rename
			extend as hash_extend,
			item as hash_item,
			at as hash_at
      undefine
         collection_extend
		end

	PICO_REQUEST_METHODS [R]
		undefine
			is_equal, copy, has_item
		end
create
	make

feature
	at alias "@", item alias "[]" (key: PATH_PICO): R assign force
		do
			check attached hash_item(key) as value then
				Result := value
			end
		end

	last_inserted_key: PATH_PICO
		attribute
			create Result.make_from_string ("")
		end

      extend(data:R; key: PATH_PICO)
      do
         check attached key as l_key then
            last_inserted_key := l_key
            hash_extend(data, l_key)
         end
      end

      collection_extend(data: R)
      local
          new_key: PATH_PICO
      do
          new_key := next_available_key
          extend(data, new_key)
          if attached {PICO_ENTITY} data as entity then
              entity.sync_with_key(new_key)
          end
      end

  next_available_key: PATH_PICO
      -- Generate "1", "2", "3", etc. based on max existing ID
      local
          max_id: INTEGER
          id_str: STRING
      do
          max_id := 0
          across current_keys as k loop
              -- Extract numeric part from PATH_PICO (e.g., "123" → 123)
              if attached k.item.out as path_str and then path_str.count > 0 then
                  id_str := path_str
                  if id_str.is_integer then
                      max_id := max_id.max(id_str.to_integer)
                  end
              end
          end
          create Result.make_from_string((max_id + 1).out)
      end

	all_keys: ITERABLE [PATH_PICO]
			-- All keys in the table
		do
			Result := current_keys
		end

end
