note
	description: "Summary description for {DNS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

once class
	DNS

create
make

feature {NONE}
	make
	once
		create store.make (10)
	end

feature -- mappers
fromStore(stored_value: WEAK_REFERENCE[RESOURCE]):RESOURCE
require
	not_collected: attached stored_value.item
do
	check attached stored_value.item as l_resource then
		Result := l_resource
	end
end

toStore(a_representation:RESOURCE):WEAK_REFERENCE[RESOURCE]
do
	create Result
	Result.put (a_representation)

end
feature -- rest verbs
	has(key:URI):BOOLEAN
	do
		Result := store.has (key.string)
	end

	item alias "[]"(key:URI):attached RESOURCE
	do
		check attached store.item(key.string) as l_weak_ref then
			Result := fromStore(l_weak_ref)
		end
	end

	post(a_resource:RESOURCE)
	do
		put(a_resource, a_resource.address)
	end

	put(a_resource:RESOURCE; key:URI)
	do
		store.put (toStore(a_resource), key.string)
	end

feature -- static registry
	register(a_resource:RESOURCE)
	local
		dns:DNS
	do
		create dns.make
		dns.post (a_resource)
	ensure
		class
	end
feature {NONE}
	--internal storage
	store : HASH_TABLE[WEAK_REFERENCE[RESOURCE],STRING]
	attribute
		create Result.make(10)
	end


end
