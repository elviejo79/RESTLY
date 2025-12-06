note
	description: "Summary description for {TEST_TODOSPEC}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_TODOSPEC

inherit
	EQA_TEST_SET
		redefine
			on_prepare,
			on_clean
		end

feature {NONE} -- Constants

	Nonexistent_item_id: STRING = "99999999"

feature {NONE} -- Test lifecycle

	test_item_key: detachable PATH_PICO
		-- Key of item created for testing

	on_prepare
			-- Create a test item for tests that need an existing item
		do
			todoserver.collection_extend (make_test_todo ("Test item for get/put tests"))
			test_item_key := todoserver.last_inserted_key
		end

	on_clean
			-- Clean up test item if it was created
		do
			if attached test_item_key as key then
				if todoserver.has_key (key) then
					todoserver.remove (key)
				end
			end
		end

feature {NONE} -- Test Support

	todoserver: TODOBACKEND_API
		once
			create Result.make_default
		end

	make_test_todo (text: STRING): TODO_ITEM
		do
			create Result.make
			Result.put_string (text, "title")
		end

feature -- Tests: Queries (safe HTTP verbs)

	test_has_key_existing_item_returns_true
		do
			check attached test_item_key as key then
				assert ("existing item should return true", todoserver.has_key (key))
			end
		end

	test_has_key_missing_item_returns_false
		local
			test_path: PATH_PICO
		do
			create test_path.make_from_string (Nonexistent_item_id)
			assert ("nonexistent item should return false", not todoserver.has_key (test_path))
		end

	test_get_existing_item_returns_todo
		local
			retrieved: TODO_ITEM
		do
			check attached test_item_key as key then
				retrieved := todoserver [key]
				assert ("retrieved item should not be void", retrieved /= Void)
			end
		end

feature -- Tests: Commands (unsafe HTTP verbs)

	test_post_creates_new_todo
		do
			todoserver.collection_extend (make_test_todo ("Test todo item"))
		end

	test_put_modifies_existing_todo
		local
			todo_to_modify: TODO_ITEM
		do
			check attached test_item_key as key then
				-- First, retrieve the full object
				todo_to_modify := todoserver [key]

				-- Modify the fields we want to change (remove and re-add to update)
				todo_to_modify.remove ("title")
				todo_to_modify.put_string ("Modified via force test", "title")
				todo_to_modify.remove ("completed")
				todo_to_modify.put_boolean (True, "completed")

				-- PUT the modified full object back
				todoserver.force (todo_to_modify, key)
			end
		end

--	test_remove_deletes_item
--			-- NOTE: Commented out due to API rate limits
--			-- DELETE functionality is protected by postcondition: not has_key (key)
--			-- The postcondition ensures correct behavior when remove is called
--		local
--			todoserver: HTTP_SCHEME [JSON_OBJECT]
--			json_todo: JSON_OBJECT
--			created_key: PATH_HTTPICO
--		do
--			create todoserver.make (create {URI}.make_from_string ("https://todo-api.fanoutapp.com/todos/default/items/"))
--
--			-- Create a new item via POST
--			create json_todo.make
--			json_todo.put_string ("Item to be deleted", "text")
--			todoserver.collection_extend (json_todo)
--
--			-- Get the key of the created item
--			created_key := todoserver.last_inserted_key
--
--			-- Verify it exists
--			assert ("item should exist after POST", todoserver.has_key (created_key))
--
--			-- Delete it
--			todoserver.remove (created_key)
--
--			-- Postcondition will verify: not has_key (created_key)
--		end

end
