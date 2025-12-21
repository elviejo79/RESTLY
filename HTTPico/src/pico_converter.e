 note
	description: "Bidirectional converter between representation type R and storage type S."

deferred class
	PICO_CONVERTER [R, S]

feature -- Conversion

	to_store (a_r: R): S
			-- Convert representation `a_r` to storage format.
		deferred
		end

	representation (a_store: S): R
			-- Convert storage `a_store` to representation format.
		deferred
		end

end
