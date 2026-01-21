deferred class PICO_CONVERTER_JSON[S -> {CONVERTIBLE_WITH_JSON, PATCHABLE}]
inherit
PICO_CONVERTER[JSON_OBJECT,S]
      undefine
      extend, force
      redefine
      linear_representation
      end
      
feature -- next state
backend: PICO_VERBS[S]

   Patch_ds: TUPLE
      local
      l_s : S
      do
        create l_s.make_empty
        Result :=  l_s.Patch_ds
      end
      
feature -- converters

to_representation(a_s:S):JSON_OBJECT
		do
      Result := a_s.to_json_object
      end

to_storage(a_r:JSON_OBJECT):S
      do
      create Result.make_from_json_object(a_r)
      end
         
      to_storage_patch(a_patch_jo:JSON_OBJECT): TUPLE
      local
      l_s:S
      do
      create l_s.make_empty
      Result := l_s.tuple_from_json_object(a_patch_jo)
      end
  
end
   
