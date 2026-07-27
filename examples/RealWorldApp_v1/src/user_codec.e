note
	description: "[
		Envelope codec for the users pipeline: wire bodies are
		wrapped in `envelope' ({"user": ...}) and password_hash
		is stripped on the way out, never reaching the wire.
		Keys pass through untouched (email on both sides).
	]"

class
	USER_CODEC

inherit
	CONVERTER [STRING, JSON_OBJECT, STRING, JSON_OBJECT]
		redefine
			default_create,
			merge
		end

create
	default_create

feature {NONE} -- Initialization

	default_create
		do
			create envelope.make_empty
		end

feature -- Configuration

	envelope: STRING assign set_envelope
			-- Wire envelope name, set at configuration time.

	set_envelope (a_name: STRING)
		do
			envelope := a_name
		end

feature -- Conversion points

	storage_key (a_key: STRING): STRING
			-- <Precursor>
		do
			Result := a_key
		end

	representation_key (a_key: STRING): STRING
			-- <Precursor>
		do
			Result := a_key
		end

	representation (a_value: JSON_OBJECT): JSON_OBJECT
			-- <Precursor>: password_hash stripped, body wrapped in `envelope`.
		local
			l_clean: JSON_OBJECT
		do
			l_clean := a_value.twin
			l_clean.remove ("password_hash")
			create Result.make_with_capacity (1)
			Result.put (l_clean, envelope)
		end

	storage_value (a_value: JSON_OBJECT): JSON_OBJECT
			-- <Precursor>: unwrap `envelope` if present, as-is if flat.
		do
			if attached {JSON_OBJECT} a_value [envelope] as l_inner then
				Result := l_inner
			else
				Result := a_value
			end
		end

feature -- Update

	merge (a_patch: JSON_OBJECT; a_k: STRING)
			-- <Precursor>: forwarded in storage space -- the inherited
			-- read-modify-write runs through `representation`, which is
			-- lossy here (password_hash stripped, body enveloped).
		do
			back.merge (storage_value (a_patch), storage_key (a_k))
		end

end
