note
	description: "An implementation of HASH_TABLE that has REST INTERFACE {REST_TABLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REST_TABLE [R]

inherit
	HASH_TABLE [R, URL_PATH]
		rename
			-- extend as hash_extend,
			item as hash_item,
			at as hash_at
		end

	REST [R]
		undefine
			is_equal, copy
		end
create
	make

feature
	at alias "@", item alias "[]" (key: URL_PATH): R assign force
		do
			check attached hash_item(key) as value then
				Result := value
			end
		end


end
