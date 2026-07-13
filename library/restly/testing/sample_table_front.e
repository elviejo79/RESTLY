note
	description: "[
		Concrete RESTLY_PIPELINE_FRONT over a POSTABLE store, for testing
		extend_new delegation: `fresh_key` must never be minted here.
		Identity converters; INTEGER keys and SAMPLE_ROW on both sides.
	]"

class
	SAMPLE_TABLE_FRONT

inherit
	RESTLY_PIPELINE_FRONT [INTEGER, SAMPLE_ROW, INTEGER, SAMPLE_ROW]

create
	make

feature -- Key minting

	fresh_key: INTEGER
			-- <Precursor>
			-- The POSTABLE store mints keys; minting here is a bug.
		do
			(create {EXCEPTIONS}).raise ("SAMPLE_TABLE_FRONT.fresh_key must never be called; the store mints ids.")
		end

feature -- Update (RESTLY_PATCHABLE)

	merge (a_patch: SAMPLE_ROW; a_k: INTEGER)
			-- Simplest legal implementation: full replace.
		do
			store.put (a_patch, key_converter.to_store (a_k))
		end

end
