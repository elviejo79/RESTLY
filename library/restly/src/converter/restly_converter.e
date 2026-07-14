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
         -- May canonicalize: `to_representation (Result)' equals
         -- `a_representation' once `a_representation' is canonical
         -- (the composite is idempotent in general).
      deferred
      ensure
         representation_round_trips: True
               -- TODO(owner): contract
               -- suggested: to_representation (Result) ~ a_representation
               -- (holds once `a_representation' is canonical; see header comment)
      end

   to_representation (a_store: S): R
         -- Convert store type to representation.
         -- May add representation-side defaults (e.g. todobackend's
         -- "completed": false); such additions define the canonical
         -- form that `to_store' round-trips against.
      deferred
      end

end
