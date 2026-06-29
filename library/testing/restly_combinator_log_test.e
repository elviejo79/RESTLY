note
	description: "Tests for RESTLY_COMBINATOR_LOG"

class
	RESTLY_COMBINATOR_LOG_TEST

inherit
	EQA_TEST_SET
		redefine on_prepare end

feature {NONE} -- Setup

	store: RESTLY_RESOURCE_BASIC_HASH [STRING, INTEGER]
	log_layer: RESTLY_COMBINATOR_LOG [STRING, INTEGER]

	on_prepare
		do
			create store.with_object_equality
			create log_layer.fronted_by (store)
			log_layer := log_layer <| store
		end

feature -- Tests

	test_extend_is_logged
		do
			log_layer.extend (42, "x")
			assert ("one entry logged", log_layer.entries.count = 1)
			assert ("op is extend", log_layer.entries.first.op ~ "extend")
		end

	test_item_is_logged
		local
			v: INTEGER
		do
			store.extend (7, "k")
			v := log_layer.item ("k")
			assert ("item logged", log_layer.entries.count = 1)
			assert ("op is item", log_layer.entries.first.op ~ "item")
		end

	test_remove_is_logged
		do
			log_layer.extend (1, "r")
			log_layer.remove ("r")
			assert ("two entries", log_layer.entries.count = 2)
			assert ("second op is remove", log_layer.entries.last.op ~ "remove")
		end

	test_ticks_are_monotonic
		do
			log_layer.extend (1, "a")
			log_layer.extend (2, "b")
			assert ("ticks increase", log_layer.entries.last.tick > log_layer.entries.first.tick)
		end

	test_does_not_break_chain
		local
			v: INTEGER
		do
			log_layer.extend (99, "z")
			assert ("store has key", store.has_key ("z"))
			v := log_layer.item ("z")
			assert ("value correct", v = 99)
		end

end
