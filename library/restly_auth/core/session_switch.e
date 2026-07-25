note
	description: "[
		Keep the keycard or reprint it? (Idea 5). A routing combinator
		memoizing principal -> view; revocation is one operation with
		one obvious name: `evict`. Staleness window equals the view's
		lifetime; evicting early beats the token's own expiry.
	]"

class
	SESSION_SWITCH [K -> HASHABLE, V]

create
	make

feature {NONE} -- Initialization

	make (a_back: RESTLY_PROTOCOL [K, V])
		do
			back := a_back
			create views.make (8)
			views.compare_objects
		end

feature -- Access

	views: HASH_TABLE [AUTH_VIEW [K, V], PRINCIPAL]
			-- Remembers: principal -> their AUTH_VIEW.

	view (a_cap: CAPABILITY): AUTH_VIEW [K, V]
			-- The memoized authorized world of `a_cap`'s subject,
			-- built on first sight.
		require
			valid: a_cap.is_valid
		do
			if attached views.item (a_cap.subject) as v then
				Result := v
			else
				create Result.make (a_cap, back)
				views.force (Result, a_cap.subject)
			end
		ensure
			bound_to_caller: Result.capability.subject ~ a_cap.subject
		end

feature -- Removal

	evict (a_subject: PRINCIPAL)
			-- Revoke: this person's authorized world ceases to exist.
		do
			views.remove (a_subject)
		ensure
			gone: not views.has (a_subject)
		end

feature {NONE} -- Implementation

	back: RESTLY_PROTOCOL [K, V]
			-- The real store every view is built over.

end
