note
	description: "[
                {RESTLY_CONVERTER_IMPLICIT} Converter that works when [R] and [S]
                are mutually conformant — delegates by direct assignment.
                ]"
	author: "agarciafdz@gmail.com"
	date: "$Date$"
	revision: "$Revision$"

class
   RESTLY_CONVERTER_IMPLICIT [R -> ANY create default_create end, S -> ANY create default_create end]

inherit
   RESTLY_CONVERTER [R, S]

create
   default_create

feature -- Conversion

   to_store (a_representation: R): S
         -- Assumes {R} conforms to {S}.
      do
      create Result
      end

   to_representation (a_store: S): R
         -- Assumes {S} conforms to {R}.
      do
      create Result
      end

end
