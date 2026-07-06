note
	description: "[
                {RESTLY_RESOURCE} Is a thing that can answer to the {RESTLY_PROTOCOL}.
                But that always answers with a
                     [R]epresentation, even tough it
                     [S]tores a different data type.
                This is typical in web, where a client sends and receives json ,
                but the server actually stores binary data.
                ]"
	author: "agarciafdz@gmail.com"
	date: "$Date$"
	revision: "$Revision$"

class
   RESTLY_RESOURCE[K -> HASHABLE, R,S]

inherit
   RESTLY_PROTOCOL [K,R] -- This class receives and returns representations, even if it can actually stores different things.

   ANY -- restores effective is_equal, copy, out, default_create deferred by RESTLY_PROTOCOL's undefine

create
   make

feature -- Store
   store : RESTLY_PROTOCOL[K,S]
     -- Anything that follows the {RESTLY_PROTOCOL} can be a store

feature {NONE} -- Implementation
   converter: RESTLY_CONVERTER[R,S]

feature -- Creation
   make(a_store:RESTLY_PROTOCOL[K,S]; a_converter: RESTLY_CONVERTER[R,S])
      do
         store := a_store
         converter := a_converter
      end

feature -- REST 

	item alias "[]" (k: K): R assign force
		do
      Result := converter.to_representation(store.item(k))
		end

	has_key (k: K): BOOLEAN
		do
      Result := store.has_key(k)
		end

	extend (a_r: R; k: K)
		do
      store.extend(converter.to_store(a_r), k)
		end

	force (a_r: R; k: K)
      do
        store.force(converter.to_store(a_r), k)
		end

	put (a_r: R; k: K)
		do
        store.put(converter.to_store(a_r), k)
		end

	remove (k: K)
		do
        store.remove(k)
		end

end
