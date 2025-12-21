class
   API_SERVICE[S -> PICO_JSON_OBJECT create make_from_separate end]

create
make


feature
make
      do
      create storage.make(10)
		end


feature --http verbs
has_key(s_key : separate URL_PATH):BOOLEAN
      local
      l_key : URL_PATH
      do
      separate s_key as key do
      create l_key.make_from_separate(key)
         Result := storage.has_key(l_key)
         end
      end

item (s_key : separate URL_PATH):S
      local
      l_key : URL_PATH
      do
      separate s_key as key do
        create l_key.make_from_separate(key)
         Result := storage.item(l_key)
         end
      end

extend(s_data:separate S)
      local
      l_key : URL_PATH
      l_data : S
      do
      separate s_data as data do
         create l_data.make_from_separate(data)
         if attached {JSON_STRING} l_data["name"] as l_name then
         create l_key.make_from_string("/"+l_name.item)
            check attached l_key as ll_key then
            storage.extend(l_data, ll_key)
               end
         end
      end
            end


force(s_data:separate S; s_key: separate URL_PATH)
      local
      l_key : URL_PATH
      l_data : S
      do
      create l_key.make_from_separate(s_key)
      separate s_data as data do
         create l_data.make_from_separate(data)
         storage.force(l_data, l_key)
      end
      end

remove(s_key: separate URL_PATH)
      local
      l_key : URL_PATH
      do
      create l_key.make_from_separate(s_key)
      storage.remove(l_key)
      end

trace(s_key: separate URL_PATH): detachable S
      local
      l_key : URL_PATH
      do
      create l_key.make_from_separate(s_key)
      Result := storage.trace(l_key)
      end

last_inserted_key: URL_PATH
      do

      Result := storage.last_inserted_key
      end

count: INTEGER_32
      do

      Result := storage.count
      end

feature {NONE}
storage: PICO_TABLE[S]
end
