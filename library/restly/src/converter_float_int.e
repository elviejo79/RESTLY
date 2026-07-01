note
	description: "[
                {CONVERTER_FLOAT_INT} Converts between REAL_32 (representation)
                and INTEGER_32 (store). Truncates on to_store.
                ]"
	author: "agarciafdz@gmail.com"
	date: "$Date$"
	revision: "$Revision$"

class
   CONVERTER_FLOAT_INT

inherit
   RESTLY_CONVERTER [REAL_32, INTEGER_32]

create
   default_create

feature -- Conversion

   to_store (a_representation: REAL_32): INTEGER_32
      do
         Result := a_representation.truncated_to_integer
      end

   to_representation (a_store: INTEGER_32): REAL_32
      do
         Result := a_store
      end

end
