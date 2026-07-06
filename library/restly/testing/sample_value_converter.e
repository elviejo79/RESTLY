note
	description: "Converts STRING representation to SAMPLE_ITEM and back for testing."

class
	SAMPLE_VALUE_CONVERTER

inherit
	RESTLY_CONVERTER [STRING, SAMPLE_ITEM]

feature -- Conversion

	to_store (a_representation: STRING): SAMPLE_ITEM
			-- Create a SAMPLE_ITEM from its title string.
		do
			create Result.make (a_representation)
		end

	to_representation (a_store: SAMPLE_ITEM): STRING
			-- Extract the title string.
		do
			Result := a_store.title
		end

end
