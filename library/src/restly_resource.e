note
	description: "[
	According to Fielding's Thesis a RESOURCE is anything worthy of a name.
	Analogous a {RESTLY_RESOURCE}. Is a service, content, file, etc. worthy of an identy.
	That is unique and that can answer restly_verbs
   it all the classes used here sholud be unique to the system.

   So this means
   this documentation
   https://www.eiffel.org/node/475
   
   and this: https://www.eiffel.org/doc/solutions/Once_features_in_multithreaded_mode
   To ensure that a once function is executed only once per process, you would use the "PROCESS" once key:

    object_per_process: OBJECT
            -- New 'object' (once per process)
            -- that could be shared between threads
            -- without reinitializing it.
        once ("PROCESS")
            create Result.make
        end
        
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	RESTLY_RESOURCE[K->HASHABLE,V]
	inherit
		RESTLY_VERBS[K,V]
end
