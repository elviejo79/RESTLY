note
	description: "Summary description for {RESOURCE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTPICO_RESOURCE

inherit
	ANY
		redefine
			copy,
			is_equal
		end
create
	make_with_url

feature {NONE}
	make_with_url (a_url: URI)
		do
			address := a_url
		end

feature --factory
	make_and_register (a_uri: URI): like Current
		local
			dns: DNS
		do
			create dns.make
			if dns.has (a_uri) and then attached {like Current} dns.item (a_uri) as stored_resource then
				Result := stored_resource
			else
				create Result.make_with_url (a_uri)
				dns.post (Result)
			end

		ensure
			class
		end

feature -- standard features from AN
	is_equal (other: like Current): BOOLEAN
		local
			are_addresses_equal: BOOLEAN
		do
			are_addresses_equal := address.is_equal (other.address)
			Result := are_addresses_equal and Precursor (other)
		end

	copy(other:like Current)
		local
			dns: DNS
		do
			create dns.make
			check dns.has (other.address) and then
			attached {like Current} dns.item (other.address) as stored_resource then
				address:= stored_resource.address
				precursor (other)
			end
		end


feature --implementation
	address: URI
		attribute
			create {URI_PICO} Result.make_from_string ("http://default")
		end

end
