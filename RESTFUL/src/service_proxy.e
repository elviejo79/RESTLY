class
   SERVICE_PROXY[S -> JSON_OBJECT create make_from_separate end]

inherit
REST[S]
      --    rename 
      -- last_inserted_key as orginal_last_inserted_key,
      --    count as original_count,
      --    make as original_make
      redefine
      -- has_key,
      --    item,
      --    extend,
      --    force,
      --    remove,
         trace
      end
      
feature -- http vebrs

has_key(key:URL_PATH):BOOLEAN

      do
      separate remote_api_service as remote do
         Result := remote.has_key(key)
            end
      end   

item alias "[]" (a_key:URL_PATH):S
      do
      separate remote_api_service as remote do
         create Result.make_from_separate(remote.item(a_key))
            end
      end

extend(data:S; key: detachable URL_PATH)
      local
      new_path : URL_PATH
      do
      separate remote_api_service as remote do
            remote.extend(data)
      end
      end

force(data:S; key: URL_PATH)
      do
      separate remote_api_service as remote do
         remote.force(data, key)
            end
      end

remove(key: URL_PATH)
      do
      separate remote_api_service as remote do
         remote.remove(key)
      end    
      end

      trace(key: URL_PATH):S
      do
      separate remote_api_service as remote do
         check attached remote.trace(key) as remote_trace_result then
            create Result.make_from_separate(remote_trace_result)
               end 
      end 
      end

last_inserted_key: URL_PATH
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
feature {NONE}
remote_api_service : separate API_SERVICE[JSON_OBJECT]
		once ("PROCESS")
			create Result.make
		end

end
