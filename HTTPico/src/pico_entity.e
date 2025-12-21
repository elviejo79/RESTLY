note
	description: "Abstract entity with auto-incrementing ID counter and custom equality"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	PICO_ENTITY

inherit
	ANY
		undefine
			is_equal
		end

feature -- Initialization

	make_empty
			-- Initialize with default values
		deferred
		end

	empty_factory: like Current
			-- Create a new empty instance for deserialization
		deferred
		ensure
			result_exists: Result /= Void
		end

feature -- Access

	id_counter: CELL [NATURAL_64]
			-- Shared counter for generating unique IDs
		deferred
		ensure
			result_exists: Result /= Void
		end

feature -- Comparison

	is_equal (other: like Current): BOOLEAN
			-- Is `other' equal to current entity?
		deferred
		end

feature -- Modification

	merge (other: like Current)
			-- Merge `other' into current entity
		deferred
		end

	sync_with_key (key: PATH_PICO)
			-- Sync entity state with storage key
			-- Override in descendants if entity needs to track storage key
		deferred
		end

end
