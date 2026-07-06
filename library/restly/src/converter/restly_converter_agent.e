class RESTLY_CONVERTER_AGENT [R, S]
inherit
	RESTLY_CONVERTER [R, S]
create
	make

feature {NONE} -- Initialization
	make (a_to_store: FUNCTION [R, S]; a_to_representation: FUNCTION [S, R])
		do
			to_store_function := a_to_store
			to_representation_function := a_to_representation
		end

feature -- Conversion
	to_store (a_representation: R): S
		do
			Result := to_store_function.item ([a_representation])
		end

	to_representation (a_store: S): R
		do
			Result := to_representation_function.item ([a_store])
		end

feature {NONE} -- Implementation
	to_store_function: FUNCTION [R, S]
	to_representation_function: FUNCTION [S, R]
end

