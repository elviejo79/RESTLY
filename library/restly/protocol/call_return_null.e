note
	description: "[
		Null handler: the unwired state of a call/return stage.
		Addresses nothing (`has_key` is always False) and the verbs
		must never be reached.
		One instance per [I, O] derivation: creation is private,
		access through `instance`.
	]"

frozen class
	CALL_RETURN_NULL [I, O]

inherit
	CALL_RETURN_PROTOCOL [I, O]

	ANY
			-- Re-effects default_create/copy/out/is_equal,
			-- which CALL_RETURN_PROTOCOL undefines for its own joins.

create {CALL_RETURN_NULL}
	default_create

feature -- Access

	instance: CALL_RETURN_NULL [I, O]
			-- A null handler for [I, O]. Stateless, so identity is
			-- irrelevant; a true once is illegal here (VFFD(7):
			-- once functions may not have a formal-generic result).
		do
			create Result
		ensure
			instance_free: class
		end

feature -- REST verbs

	item alias "[]" (req: I): O
			-- <Precursor>
		do
			check this_should_never_be_called: False then
				Result := item (req)
			end
		end

	head (req: I): O
			-- <Precursor>
		do
			check this_should_never_be_called: False then
				Result := head (req)
			end
		end

	has_key (req: I): BOOLEAN
			-- <Precursor>: nothing here.
		do
			Result := False
		end

	extend (req: I): O
			-- <Precursor>
		do
			check this_should_never_be_called: False then
				Result := extend (req)
			end
		end

	put (req: I): O
			-- <Precursor>
		do
			check this_should_never_be_called: False then
				Result := put (req)
			end
		end

	remove (req: I): O
			-- <Precursor>
		do
			check this_should_never_be_called: False then
				Result := remove (req)
			end
		end

	items (req: I): O
			-- <Precursor>
		do
			check this_should_never_be_called: False then
				Result := items (req)
			end
		end

	wipe_out (req: I): O
			-- <Precursor>
		do
			check this_should_never_be_called: False then
				Result := wipe_out (req)
			end
		end

	merge (req: I): O
			-- <Precursor>
		do
			check this_should_never_be_called: False then
				Result := merge (req)
			end
		end

	preflight_ok (req: I): O
			-- <Precursor>
		do
			check this_should_never_be_called: False then
				Result := preflight_ok (req)
			end
		end

feature -- Request queries

	element_key (req: I): ANY
			-- <Precursor>
		do
			check this_should_never_be_called: False then
				Result := element_key (req)
			end
		end

	parse_body (req: I): ANY
			-- <Precursor>
		do
			check this_should_never_be_called: False then
				Result := parse_body (req)
			end
		end

	id_parameter_name: STRING
			-- <Precursor>
		do
			Result := "id"
		end

end
