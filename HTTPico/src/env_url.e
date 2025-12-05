note
	description: "An {ENV_URL} is a URL that only has the 'env://' scheme part. Because it is used for environment variables"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENV_URL

inherit
	URI
create
	make_from_string
invariant
	scheme_is_env : "env" = scheme

end
