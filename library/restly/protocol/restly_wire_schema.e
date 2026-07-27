note
	description: "[
		Wire schema of one resource: envelope names and address-derived
		fields, all Void by default (flat bodies, nothing derived).
		Declared by the stage that knows the resource -- a codec or a
		store -- and adopted by the HTTP-boundary handler when the
		pipeline is composed; names set explicitly on the handler win.
	]"

class
	RESTLY_WIRE_SCHEMA

feature -- Wire schema

	element_envelope: detachable STRING assign set_element_envelope
			-- Wire envelope around one element (e.g. "article"):
			-- unwrapped from request bodies, wrapped around element
			-- responses. Void = flat bodies.

	set_element_envelope (a_name: detachable STRING)
			-- Envelope element bodies under `a_name`.
		do
			element_envelope := a_name
		end

	collection_envelope: detachable STRING assign set_collection_envelope
			-- Wire envelope around the collection (e.g. "articles"):
			-- the collection answers {name: [...], nameCount: n}.
			-- Void = flat array.

	set_collection_envelope (a_name: detachable STRING)
			-- Envelope the collection under `a_name`.
		do
			collection_envelope := a_name
		end

	key_field: detachable STRING assign set_key_field
			-- Field of element representations receiving the element key
			-- (e.g. "slug"). Derived on the way out, never stored.

	set_key_field (a_name: detachable STRING)
			-- Echo the element key into field `a_name`.
		do
			key_field := a_name
		end

	url_field: detachable STRING assign set_url_field
			-- Field of element representations receiving the element's
			-- absolute URL. Derived on the way out, never stored.

	set_url_field (a_name: detachable STRING)
			-- Echo the element URL into field `a_name`.
		do
			url_field := a_name
		end

end
