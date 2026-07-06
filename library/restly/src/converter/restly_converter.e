note
	description: "[
                {RESTLY_CONVERTER} Abstract converter between a [R]epresentation
                and a [S]tore type.
                ]"
	author: "agarciafdz@gmail.com"
	date: "$Date$"
	revision: "$Revision$"

deferred class
   RESTLY_CONVERTER [R, S]

feature -- Conversion

   to_store (a_representation: R): S
         -- Convert representation to store type.
      deferred
      end

   to_representation (a_store: S): R
         -- Convert store type to representation.
      deferred
      end

end
