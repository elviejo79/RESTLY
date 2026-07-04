note
	description: "Shared test cases for RESTLY_RESOURCE [STRING, EMPLOYEE, PERSON]. Subclasses supply `conv'."
	author: "agarciafdz@gmail.com"

deferred class
	TEST_RESTLY_RESOURCE_EMPLOYEE

inherit
	EQA_TEST_SET

feature {NONE} -- Fixture

	store: RESTLY_HASH_TABLE [STRING, PERSON]
		attribute create Result.with_object_equality end

	conv: RESTLY_CONVERTER [EMPLOYEE, PERSON]
		deferred
		end

	res: RESTLY_RESOURCE [STRING, EMPLOYEE, PERSON]
		attribute create Result.make (store, conv) end

feature -- Tests

	test_extend_then_has_key
		do
			res.extend (create {EMPLOYEE}.make ("Alice", 0), "alice")
			assert ("key present after extend", res.has_key ("alice"))
		end

	test_item_preserves_name
		do
			res.extend (create {EMPLOYEE}.make ("Alice", 0), "alice")
			assert ("name preserved", res ["alice"].name ~ "Alice")
		end

	test_item_id_is_hash_of_name
		local
			name: STRING
		do
			name := "Alice"
			res.extend (create {EMPLOYEE}.make (name, 0), "alice")
			assert ("id is hash of name", res ["alice"].employee_id = name.hash_code)
		end

	test_force_on_new_key
		do
			res.force (create {EMPLOYEE}.make ("Alice", 0), "alice")
			assert ("key present after force", res.has_key ("alice"))
		end

	test_force_overwrites_existing
		do
			res.extend (create {EMPLOYEE}.make ("Alice", 0), "alice")
			res.force (create {EMPLOYEE}.make ("Bob", 0), "alice")
			assert ("name updated after force", res ["alice"].name ~ "Bob")
		end

	test_put_updates_existing
		do
			res.extend (create {EMPLOYEE}.make ("Alice", 0), "alice")
			res.put (create {EMPLOYEE}.make ("Bob", 0), "alice")
			assert ("name updated after put", res ["alice"].name ~ "Bob")
		end

	test_remove_deletes_key
		do
			res.extend (create {EMPLOYEE}.make ("Alice", 0), "alice")
			res.remove ("alice")
			assert ("key gone after remove", not res.has_key ("alice"))
		end

end
