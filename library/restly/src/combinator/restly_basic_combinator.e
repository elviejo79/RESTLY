deferred class
	RESTLY_BASIC_COMBINATOR [K -> HASHABLE, R, S]

inherit
	RESTLY_PROTOCOL [K, R]

feature -- Components

	front: RESTLY_PROTOCOL [K, R]
	back: detachable RESTLY_PROTOCOL [K, S]

feature -- Creation

	make (a_front: RESTLY_PROTOCOL [K, R])
		do
			front := a_front
		end

feature -- Factory

	new_with_front alias "-" (a_front: RESTLY_PROTOCOL [K, R]): RESTLY_BASIC_COMBINATOR [K, R, S]
		deferred
		end

	backed_by alias "<|" (a_back: RESTLY_PROTOCOL [K, S]): RESTLY_BASIC_COMBINATOR [K, R, S]
		deferred
		end

end -- class
