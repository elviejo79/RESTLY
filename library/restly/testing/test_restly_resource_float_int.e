note
	description: "Tests for RESTLY_RESOURCE [STRING, REAL_32, INTEGER_32] using CONVERTER_FLOAT_INT."
	author: "agarciafdz@gmail.com"
	date: "$Date$"
	revision: "$Revision$"

class
   TEST_RESTLY_RESOURCE_FLOAT_INT

inherit
   EQA_TEST_SET

feature {NONE} -- Fixture

  conv: RESTLY_CONVERTER_AGENT[REAL_32, INTEGER_32]
     attribute
     create Result.make(agent (a_r: REAL_32): INTEGER_32 do Result := a_r.truncated_to_integer end, agent (a_s: INTEGER_32): REAL_32 do Result := a_s end)
     end

   store: RESTLY_HASH_TABLE [STRING, INTEGER_32]
      attribute create Result.with_object_equality end

   res: RESTLY_RESOURCE [STRING, REAL_32, INTEGER_32]
      attribute create Result.make (store, conv) end

feature -- Tests

   test_has_key_false_on_empty
      do
         assert ("empty resource has no key", not res.has_key ("price"))
      end

   test_extend_then_has_key
      do
         res.extend (3.7, "price")
         assert ("key present after extend", res.has_key ("price"))
      end

   test_extend_then_item_is_truncated
      do
         res.extend (3.7, "price")
         assert ("3.7 truncates to 3.0", res ["price"] ~ {REAL_32} 3.0)
      end

   test_force_on_empty_key
      do
         res.force (5.9, "price")
         assert ("key present after force", res.has_key ("price"))
         assert ("5.9 truncates to 5.0", res ["price"] ~ {REAL_32} 5.0)
      end

   test_force_overwrites_existing
      do
         res.extend (3.7, "price")
         res.force (5.9, "price")
         assert ("force overwrites: 5.9 truncates to 5.0", res ["price"] ~ {REAL_32} 5.0)
      end

   test_put_updates_existing
      do
         res.extend (3.7, "price")
         res.put (5.9, "price")
         assert ("put updates: 5.9 truncates to 5.0", res ["price"] ~ {REAL_32} 5.0)
      end

   test_remove_deletes_key
      do
         res.extend (3.7, "price")
         res.remove ("price")
         assert ("key gone after remove", not res.has_key ("price"))
      end

end
