note
	description: "Tests for RESTLY_JSON_PIPELINE_FRONT."

class
	TEST_RESTLY_JSON_PIPELINE_FRONT

inherit
	EQA_TEST_SET

feature -- Tests: fresh_key

	test_fresh_key_increments
		local
			l_front: RESTLY_JSON_PIPELINE_FRONT [INTEGER, JSON_OBJECT]
		do
			l_front := new_front
			assert ("first key", l_front.fresh_key.same_string ("1"))
			assert ("second key", l_front.fresh_key.same_string ("2"))
			assert ("third key", l_front.fresh_key.same_string ("3"))
		end

feature -- Tests: merge (RFC 7386)

	test_merge_replaces_present_field
		local
			l_front: RESTLY_JSON_PIPELINE_FRONT [INTEGER, JSON_OBJECT]
			l_original, l_patch, l_result: JSON_OBJECT
			l_key_title: JSON_STRING
		do
			l_front := new_front
			l_original := new_json_object ("title", "old")
			l_front.extend (l_original, "1")
			l_patch := new_json_object ("title", "new")
			l_front.merge (l_patch, "1")
			l_result := l_front ["1"]
			l_key_title := "title"
			check attached l_result.string_item (l_key_title) as l_val then
				assert ("replaced", l_val.unescaped_string_8.same_string ("new"))
			end
		end

	test_merge_keeps_absent_field
		local
			l_front: RESTLY_JSON_PIPELINE_FRONT [INTEGER, JSON_OBJECT]
			l_original, l_patch, l_result: JSON_OBJECT
			l_key_title, l_key_done: JSON_STRING
		do
			l_front := new_front
			l_original := new_json_object ("title", "keep me")
			l_original.put_string ("extra", "done")
			l_front.extend (l_original, "1")
			l_patch := new_json_object ("done", "yes")
			l_front.merge (l_patch, "1")
			l_result := l_front ["1"]
			l_key_title := "title"
			l_key_done := "done"
			check attached l_result.string_item (l_key_title) as l_val then
				assert ("title unchanged", l_val.unescaped_string_8.same_string ("keep me"))
			end
			check attached l_result.string_item (l_key_done) as l_val then
				assert ("done replaced", l_val.unescaped_string_8.same_string ("yes"))
			end
		end

feature -- Tests: extend_new

	test_extend_new_mints_key
		local
			l_front: RESTLY_JSON_PIPELINE_FRONT [INTEGER, JSON_OBJECT]
			l_json: JSON_OBJECT
		do
			l_front := new_front
			l_json := new_json_object ("title", "item1")
			l_front.extend_new (l_json, "req_1")
			check attached l_front.extend_requests ["req_1"] as l_key then
				assert ("key minted", l_key.same_string ("1"))
				assert ("stored", l_front.has_key (l_key))
			end
		end

	test_extend_new_idempotent
		local
			l_front: RESTLY_JSON_PIPELINE_FRONT [INTEGER, JSON_OBJECT]
			l_json: JSON_OBJECT
		do
			l_front := new_front
			l_json := new_json_object ("title", "item1")
			l_front.extend_new (l_json, "req_1")
			l_front.extend_new (l_json, "req_1")
			assert ("count unchanged", l_front.count = 1)
			check attached l_front.extend_requests ["req_1"] as l_key then
				assert ("same key", l_key.same_string ("1"))
			end
		end

feature -- Tests: MappingStore identity default (SC '19 symmetry)

	test_identity_converters_behave_as_passthrough
			-- A front wired with both identity converters is
			-- observationally a PASSTHROUGH over its store —
			-- Weiher's "abstract mapper defaults to PassThrough".
		local
			l_bare: RESTLY_HASH_TABLE [STRING, JSON_OBJECT]
			l_front: RESTLY_JSON_RESOURCE
			l_json: JSON_OBJECT
		do
			create l_bare.with_object_equality
			create l_front
			l_json := new_json_object ("title", "same")
			l_bare.extend (l_json, "k")
			l_front.extend (l_json, "k")
			assert ("has_key agrees", l_bare.has_key ("k") = l_front.has_key ("k"))
			assert ("item agrees", l_bare ["k"] = l_front ["k"])
			l_bare.remove ("k")
			l_front.remove ("k")
			assert ("remove agrees", l_bare.has_key ("k") = l_front.has_key ("k"))
		end

feature {NONE} -- Helpers

	new_front: RESTLY_JSON_PIPELINE_FRONT [INTEGER, JSON_OBJECT]
		local
			l_table: RESTLY_HASH_TABLE [INTEGER, JSON_OBJECT]
			l_key_conv: SAMPLE_KEY_CONVERTER
			l_val_conv: RESTLY_IDENTITY_CONVERTER [JSON_OBJECT]
		do
			create l_table
			create l_key_conv
			create l_val_conv
			create Result.make (l_table, l_key_conv, l_val_conv)
		end

	new_json_object (a_key, a_value: STRING): JSON_OBJECT
		do
			create Result.make_with_capacity (2)
			Result.put_string (a_value, a_key)
		end

end
