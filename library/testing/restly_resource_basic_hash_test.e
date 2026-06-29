note
    description: "Tests for RESTLY_RESOURCE_BASIC_HASH"

class
    RESTLY_RESOURCE_BASIC_HASH_TEST

inherit
    EQA_TEST_SET

feature -- Tests

    test_extend_and_get
            -- Adding a new entry and retrieving it returns the same value.
        local
            table: RESTLY_RESOURCE_BASIC_HASH [STRING, INTEGER]
        do
            create table.with_object_equality
            table.extend (42, "answer")
            assert ("value retrieved", table.item ("answer") = 42)
        end

    test_has_key_after_extend
            -- has_key is true after extending with a key.
        local
            table: RESTLY_RESOURCE_BASIC_HASH [STRING, INTEGER]
        do
            create table.with_object_equality
            table.extend (1, "one")
            assert ("has key", table.has_key ("one"))
        end

    test_count_increments
            -- count goes up after each extend.
        local
            table: RESTLY_RESOURCE_BASIC_HASH [STRING, INTEGER]
        do
            create table.with_object_equality
            assert ("starts empty", table.count = 0)
            table.extend (1, "a")
            assert ("count is 1", table.count = 1)
            table.extend (2, "b")
            assert ("count is 2", table.count = 2)
        end

    test_put_updates_existing
            -- put replaces the value for an existing key.
        local
            table: RESTLY_RESOURCE_BASIC_HASH [STRING, INTEGER]
        do
            create table.with_object_equality
            table.extend (1, "x")
            table.put (99, "x")
            assert ("value updated", table.item ("x") = 99)
        end

    test_remove
            -- Removing a key means it is no longer present.
        local
            table: RESTLY_RESOURCE_BASIC_HASH [STRING, INTEGER]
        do
            create table.with_object_equality
            table.extend (99, "x")
            table.remove ("x")
            assert ("key removed", not table.has_key ("x"))
        end

end
