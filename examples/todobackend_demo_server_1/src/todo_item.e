note
	description: "Todo item with custom equality based only on text and completed fields"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TODO_ITEM

inherit
	PICO_ENTITY

create
	make,
	make_empty,
   make_from_string

feature -- Initialization

	make (a_id: STRING; a_title: STRING; a_completed: BOOLEAN; a_order: INTEGER)
			-- Initialize with all attributes
		do
			id := a_id
			title := a_title
			completed := a_completed
			order := a_order
		end

	make_empty
			-- Initialize with default values
		do
			id_counter.put (id_counter.item + 1)
			id := id_counter.item.out
			create title.make_empty
			completed := False
			order := 0
		end

	id_counter: CELL [NATURAL_64]
			-- Shared counter for generating unique IDs
		once
			create Result.put (0)
		end

	empty_factory: like Current
			-- Create a new empty instance for deserialization
		do
			create Result.make_empty
		end

	make_from_string (a_s: READABLE_STRING_8)
			-- Initialize from STRING (JSON representation)
		do
			make_empty
			-- Parse JSON string and extract fields
			-- This is a placeholder implementation
		end

feature -- Access

	id: STRING assign set_id
	title: STRING
	completed: BOOLEAN
	order: INTEGER

	set_id (a_id: STRING)
			-- Set id field
		do
			id := a_id
		end

	path: STRING
		do
			create Result.make_from_string ("./" + id)
		end

	url (base_url: IMMUTABLE_STRING_32): IMMUTABLE_STRING_32
		do
			Result := base_url + path
		end

feature -- Modification

	merge (other: like Current)
			-- Merge `other' into current TODO_ITEM
		do
			if attached other.title and then not other.title.is_empty then
				title := other.title
			end
			if completed /= other.completed then
         completed := other.completed
         end
         if order /= 0 then
			order := other.order
         end
		end

	sync_with_key (key: PATH_PICO)
			-- Sync item's id with storage key (strip leading "/")
		local
			key_str: STRING
		do
			key_str := key.out
			if key_str.count > 1 and then key_str[1] = '/' then
				set_id (key_str.substring (2, key_str.count))
			end
		end

feature -- Comparison

	is_equal (other: like Current): BOOLEAN
			-- Is `other' equal to current TODO_ITEM?
			-- Only compares id, title, and completed fields, ignoring order
		do
			Result := id ~ other.id and
			          title ~ other.title and
			          completed ~ other.completed
		end

end
