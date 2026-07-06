note
	description: "[
		Deferred execution that wires RESTLY pipelines to EWF.
		Inherit and implement setup_router using
		map_uri_template_response from the helper.
	]"

deferred class
	RESTLY_EWF_SERVER

inherit
	WSF_ROUTED_EXECUTION

	WSF_ROUTED_URI_TEMPLATE_HELPER

end
