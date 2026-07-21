deferred class
	COMBINATOR [K -> ANY, V -> ANY]

inherit
	RESTLY_PROTOCOL [K, V]

feature -- Components

	front: RESTLY_PROTOCOL [K, V]
	back: detachable RESTLY_PROTOCOL [ANY, ANY]

feature -- Creation

	make (a_front: RESTLY_PROTOCOL [K, V])
		do
			front := a_front
		end

	make_with_back (a_front: RESTLY_PROTOCOL [K, V]; a_back: RESTLY_PROTOCOL [ANY, ANY])
		do
      front := a_front
      back := a_back
		end
      
feature -- Factory

	new_with_parts (a_front: RESTLY_PROTOCOL [K, V]; a_back: detachable RESTLY_PROTOCOL [ANY, ANY]): COMBINATOR [K, V]
			-- A fresh combinator of my kind with the given parts.
			-- The single creation point descendants must provide;
			-- all chaining logic below stays here.
		deferred
		end

	with  (a_front: RESTLY_PROTOCOL [K, V]): COMBINATOR [K, V]
			-- note: was `instance_free: class` in the sketch, but calling
			-- deferred `new_with_parts` needs an instance.
		do
			Result := new_with_parts (a_front, Void)
		end

	backed_by alias "<|" (a_back: RESTLY_PROTOCOL [ANY, ANY]): COMBINATOR [K, V]
		do
			if attached {COMBINATOR [ANY, ANY]} back as b then
				Result := new_with_parts (front, b <| a_back)
			else
				Result := new_with_parts (front, a_back)
			end
		end

	fronted_by  (a_front: RESTLY_PROTOCOL [ANY, ANY]): COMBINATOR [K, V]
			-- TODO(sketch): nested case was unfinished:
         -- `create Result.make_with_back (f.fronted_by(, b <| a_back)`
			-- stubbed below to parse — needs your intent.
		do
			if attached {COMBINATOR [ANY, ANY]} a_front as f then
				Result := new_with_parts (front, f)
			else
				Result := new_with_parts (front, a_front)
			end
		end
      
end -- class
