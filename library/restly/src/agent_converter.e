note
	description: "[
                {AGENT_CONVERTER} implements {RESTLY_CONVERTER} by delegating
                to two injected agents.
                General-purpose, contract-free converter for any (R, S) pair.

                Usage example -- INTEGER_32 / REAL_64 pair via inline agents:
                   local
                      conv: AGENT_CONVERTER [INTEGER_32, REAL_64]
                      store: RESTLY_VERBS_HASH_TABLE [STRING, REAL_64]
                      res: RESTLY_RESOURCE [STRING, INTEGER_32, REAL_64]
                   do
                      create conv.make (
                         agent (r: INTEGER_32): REAL_64 do Result := r.to_real_64 end,
                         agent (s: REAL_64): INTEGER_32 do Result := s.truncated_to_integer end)
                      create store.with_object_equality
                      create res.make (store, conv)
                      -- res is now an RESTLY_RESOURCE [STRING, INTEGER_32, REAL_64]
                      -- No subclass required for this (R, S) pair.
                   end
                ]"
	author: "agarciafdz@gmail.com"
	date: "$Date$"
	revision: "$Revision$"

class
   AGENT_CONVERTER [R, S]

inherit
   RESTLY_CONVERTER [R, S]

create
   make

feature -- Creation

   make (a_to_store: FUNCTION [TUPLE [R], S]; a_to_representation: FUNCTION [TUPLE [S], R])
      do
         to_store_fn := a_to_store
         to_representation_fn := a_to_representation
      end

feature {NONE} -- Implementation

   to_store_fn: FUNCTION [R, S]
   to_representation_fn: FUNCTION [S, R]

feature -- Conversion

   to_store (a_representation: R): S
      do
         Result := to_store_fn(a_representation)
      end

   to_representation (a_store: S): R
      do
         Result := to_representation_fn(a_store)
      end

end
