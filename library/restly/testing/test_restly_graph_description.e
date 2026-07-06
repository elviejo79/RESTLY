note
	description: "Tests for graph_description: GraphViz dot rendering of compositions."

class
	TEST_RESTLY_GRAPH_DESCRIPTION

inherit
	EQA_TEST_SET

feature {NONE} -- Fixtures

	leaf: RESTLY_HASH_TABLE [STRING, INTEGER]
		attribute create Result.with_object_equality end

feature -- Tests

	test_leaf_is_single_node
		local
			g: STRING
		do
			g := leaf.graph_description
			assert ("digraph wrapper", g.starts_with ("digraph"))
			assert ("closes", g.ends_with ("}%N"))
			assert ("names the class", g.has_substring ("RESTLY_HASH_TABLE"))
			assert ("leaf has no edges", not g.has_substring ("->"))
		end

	test_cache_graph_has_front_and_back_edges
		local
			f, b: RESTLY_HASH_TABLE [STRING, INTEGER]
			c: RESTLY_CACHE [STRING, INTEGER]
			g: STRING
		do
			create f.with_object_equality
			create b.with_object_equality
			create c.make_with_back (f, b)
			g := c.graph_description
			assert ("names cache", g.has_substring ("RESTLY_CACHE"))
			assert ("front edge labeled", g.has_substring ("[label=%"front%"]"))
			assert ("back edge labeled", g.has_substring ("[label=%"back%"]"))
			assert ("exactly two edges", g.occurrences ('>') = 2)
		end

	test_front_graph_names_converters
		local
			inner: RESTLY_HASH_TABLE [INTEGER, SAMPLE_ITEM]
			front: SAMPLE_FRONT
			g: STRING
		do
			create inner.with_object_equality
			create front.make (inner, create {SAMPLE_KEY_CONVERTER}, create {SAMPLE_VALUE_CONVERTER})
			g := front.graph_description
			assert ("names front", g.has_substring ("SAMPLE_FRONT"))
			assert ("names key converter", g.has_substring ("SAMPLE_KEY_CONVERTER"))
			assert ("names value converter", g.has_substring ("SAMPLE_VALUE_CONVERTER"))
			assert ("edge to store", g.has_substring ("[label=%"store%"]"))
			assert ("names inner store", g.has_substring ("RESTLY_HASH_TABLE"))
		end

	test_passthrough_graph_chains
		local
			ht: RESTLY_HASH_TABLE [STRING, INTEGER]
			p: RESTLY_PASSTHROUGH [STRING, INTEGER]
			g: STRING
		do
			create ht.with_object_equality
			create p.make (ht)
			g := p.graph_description
			assert ("names passthrough", g.has_substring ("RESTLY_PASSTHROUGH"))
			assert ("edge to backend", g.has_substring ("[label=%"backend%"]"))
		end

end
