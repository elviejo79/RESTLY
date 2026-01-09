class
   SERVICE_PROXY[S -> PICO_JSON_OBJECT create make_from_separate end]

inherit
PICO_REQUEST_METHODS[S]

feature -- http vebrs

has_key(key:PATH_PICO):BOOLEAN

      do
      separate remote_api_service as remote do
         Result := remote.has_key(key)
            end
      end

item alias "[]" (a_key:PATH_PICO):S
      do
      separate remote_api_service as remote do
         create Result.make_from_separate(remote.item(a_key))
            end
      end

collection_extend(data:S)
      do
      separate remote_api_service as remote do
            remote.collection_extend(data)
      end
      end

force(data:S; key: PATH_PICO)
      do
      separate remote_api_service as remote do
         remote.force(data, key)
            end
      end

remove(key: PATH_PICO)
      do
      separate remote_api_service as remote do
         remote.remove(key)
      end
      end

last_inserted_key: PATH_PICO
      do
      separate remote_api_service as remote do
         create Result.make_from_separate(remote.last_inserted_key)
      end
      end

   count:INTEGER_32
      do
      separate remote_api_service as remote do
         Result := remote.count
         end
      end

	all_keys: ITERABLE [PATH_PICO]
			-- All keys from remote service
		local
			keys_list: ARRAYED_LIST [PATH_PICO]
		do
			create keys_list.make (0)
			separate remote_api_service as remote do
				across remote.all_keys as k loop
					keys_list.extend (create {PATH_PICO}.make_from_string (k.item.out))
				end
			end
			Result := keys_list
		end

feature {NONE}
remote_api_service : separate API_SERVICE[PICO_JSON_OBJECT]
		once ("PROCESS")
			create Result.make
		end

end
