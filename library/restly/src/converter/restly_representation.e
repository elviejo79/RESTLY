note
	description: "[
		Typed representation of a storage type S. This is the thesis's
		'deliberate rejection of untyped uniformity' made into a class:
		HTTP and Weiher treat representations as untyped bags; here a
		representation is a class that can carry its schema as an
		invariant and its value-level validity as `is_storable'.

		CONTRACT WITH REPRESENTATION_CONVERTER (read before subclassing):
		effective descendants MUST list `make_from_store' in their
		`create' clause. The creation constraint
			[R -> RESTLY_REPRESENTATION [S] create make_from_store end, S]
		is what licenses `create Result.make_from_store (a_store)' inside
		generic scope -- the only legal way a generic class can create
		instances of a formal parameter.

		Descendants that also inherit from a JSON/XML library class
		(e.g. PERSON_JSON inheriting JSON_OBJECT) may additionally declare
		a `convert' clause toward S. Rule (agreed): conversions may fire
		only inside RESTLY_CONVERTER implementations, where the boundary
		is explicit and `is_storable' has run. An implicit conversion in
		pipeline or domain code is a defect.
	]"
	author: "agarciafdz@gmail.com"

deferred class RESTLY_REPRESENTATION [S]

--convert  -- this is a reminder that you need to activate the 
   -- make_from_store({S})
   -- to_store:{S}
   
--create
   -- make_from_store
   
feature -- Initialization

	make_from_store (a_store: S)
			-- Build representation from `a_store`.
		deferred
		end

feature -- Conversion

	to_store: S
		deferred
		end

end


