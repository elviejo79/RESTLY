note
	description: "Summary description for {REST}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	REST[R]

inherit
	REST_W_STORAGE[R,R]

feature -- http Verb
	trace(key:URL_PATH):R
	do
		Result := item(key)
	end
end
