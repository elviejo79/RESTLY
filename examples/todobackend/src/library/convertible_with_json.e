deferred class CONVERTIBLE_WITH_JSON

feature -- convertible with JSON_OBJECT
to_json_object: JSON_OBJECT
   		local
			fac: JSON_SERIALIZATION_FACTORY
			conv: JSON_SERIALIZATION
      do
      conv := fac.reflector_serialization
         check attached {JSON_OBJECT} conv.to_json(Current) as l_r then
         Result := l_r
         end
      end

         
  tuple_from_json_object(a_jo:JSON_OBJECT): TUPLE
      deferred
      ensure
         instance_free: class
      end

feature {NONE} 
      make_from_json_object(a_jo:JSON_OBJECT)
      deferred
      end

end
