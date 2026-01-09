deferred class CONVERTIBLE_WITH_STRING_32
	-- Conversion support for STRING_32
	-- Note: heirs must include make_from_string_32 in their create clause
	-- and add conversion in their convert clause
feature {NONE} -- Initialization

	make_from_string_32 (s: STRING_32)
		deferred
		end

feature -- Conversion

	to_string_32: STRING_32
		deferred
		end

end
