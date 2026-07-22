note
	description: "A resource addressed by a scheme URL; cached by {SCHEME}."

deferred class
	RESTLY_RESOURCE

feature -- Access

	base_url: URI_TEMPLATE
			-- Absolute URI naming this resource's root; registry key.

end
