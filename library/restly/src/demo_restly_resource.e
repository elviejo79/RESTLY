note
	description: "[
                Demonstrates RESTLY_RESOURCE instantiated with AGENT_CONVERTER
                for two different (R, S) pairs — no subclass required for either.
                Serves as the ECF root class for restly_resource.ecf.
                ]"
	author: "agarciafdz@gmail.com"
	date: "$Date$"
	revision: "$Revision$"

class
   DEMO_RESTLY_RESOURCE

create
   make

feature -- Demo

   make
         -- Instantiate RESTLY_RESOURCE for INTEGER_32/REAL_64 and STRING/INTEGER_32 pairs.
      local
         conv_i_r: AGENT_CONVERTER [INTEGER_32, REAL_64]
         store_i_r: RESTLY_VERBS_HASH_TABLE [STRING, REAL_64]
         res_i_r: RESTLY_RESOURCE [STRING, INTEGER_32, REAL_64]

         conv_s_i: AGENT_CONVERTER [STRING, INTEGER_32]
         store_s_i: RESTLY_VERBS_HASH_TABLE [STRING, INTEGER_32]
         res_s_i: RESTLY_RESOURCE [STRING, STRING, INTEGER_32]
      do
            -- Pair 1: representation=INTEGER_32, store=REAL_64
         create conv_i_r.make (
            agent (r: INTEGER_32): REAL_64 do Result := r end,
            agent (s: REAL_64): INTEGER_32 do Result := s.truncated_to_integer end)
         create store_i_r.with_object_equality
         create res_i_r.make (store_i_r, conv_i_r)

            -- Pair 2: representation=STRING, store=INTEGER_32
         create conv_s_i.make (
            agent (r: STRING): INTEGER_32 do Result := r.to_integer end,
            agent (s: INTEGER_32): STRING do Result := s.out end)
         create store_s_i.with_object_equality
         create res_s_i.make (store_s_i, conv_s_i)
      end

end
