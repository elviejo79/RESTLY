note
	description: "[
There are middlewares that act under the CALL/RETURN paradigm.
Most notably the Eiffel Web Framework that sends a WSF_REQUEST and expects a WSF_RESPONSE
Menaning that they expect a return value immediately after any call.
So in order to connect with them, we create this decorator.
]"
	author: "agarciafdz@gmail.com"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CALL_RETURN_PROTOCOL [I, O]

inherit
	ANY
		undefine
			is_equal,
			copy,
			out,
			default_create
		end

feature -- REST verbs

	item alias "[]" (req: I): O
			-- GET: response for the resource addressed by `req`.
		require
			error_404_not_found: has_key (req)
		deferred
		end

	head (req: I): O
			-- HEAD: response for the resource addressed by `req`, without body.
		deferred
		end

	has_key (req: I): BOOLEAN
			-- Basic query: is the resource addressed by `req` present?
			-- Used by contracts, not mapped to an HTTP verb itself.
		deferred
		end

	extend (req: I): O
			-- POST: create the resource carried by `req`.
			-- contract to author: I/O form of error_500_didnt_actually_insert
		deferred
		end

	force (req: I): O
			-- PUT: upsert the resource carried by `req`.
			-- contract to author: I/O form of error_500_didnt_actually_insert
		do
			if has_key (req) then
				Result := put (req)
			else
				Result := extend (req)
			end
		end

	put (req: I): O
			-- PUT with exists: update an existing resource.
			-- contracts to author: I/O forms of has_key precondition
			-- and error_500_didnt_actually_update
		deferred
		end

	remove (req: I): O
			-- DELETE: remove the resource addressed by `req`.
			-- contracts to author: I/O forms of has_key precondition
			-- and error_500_didnt_actually_delete
		deferred
		end

feature -- Request queries

	element_key (req: I): ANY
			-- Key of the element addressed by `req`.
		deferred
		end

	parse_body (req: I): ANY
			-- Payload carried by `req`.
		deferred
		end

feature -- Output

	graph_description: STRING
			-- Composition rooted at this store as a GraphViz digraph
			-- (SC '19 §4 auto-diagrams; render with `dot -Tpdf').
			-- `a -> b' reads "a is backed by b" — the inversion of
			-- Weiher's source-to-front arrows.
		do
			create Result.make_from_string ("digraph restly {%Nrankdir=LR;%N")
			Result.append (graph_dot_lines)
			Result.append ("}%N")
		end

	graph_node_id: STRING
			-- GraphViz node id, unique per object (address-based).
		do
			Result := "n" + ($Current).out
		end

	graph_dot_lines: STRING
			-- Dot lines for this node and everything behind it.
			-- Leaf default: a single labeled node; combinators
			-- redefine to add their children and labeled edges.
		do
			create Result.make_from_string (graph_node_id)
			Result.append (" [label=%"")
			Result.append (generating_type.name)
			Result.append ("%"];%N")
		end

end
