class
   API_SERVICE[S -> JSON_OBJECT create make_from_separate end]

create
make


feature
make
               local
			alice_path, bob_path: URL_PATH
      do
      create storage.make(10)
			-- -- Result := {RESOURCE_TABLE[JSON_OBJECT]}.make_and_register("http://localhost/my_table")
			-- create alice_path.make_from_string ("/alice")
			-- create bob_path.make_from_string ("/bob")
			-- storage [alice_path] := create {JSON_OBJECT}.make_with_capacity (2)
			-- storage [alice_path].put_string ("alice", "name")
			-- storage [alice_path].put_integer (20, "age")
			-- storage [bob_path] := create {JSON_OBJECT}.make_with_capacity (2)
			-- storage [bob_path].put_string ("bob", "name")
			-- storage [bob_path].put_integer (30, "age")
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
            print ("calculated ll_key: " + ll_key.out + "%N")
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
storage: REST_TABLE[S]
end
