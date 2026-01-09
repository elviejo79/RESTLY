deferred class CONVERTIBLE_WITH_JSON_VALUE
	-- Conversion support for JSON_VALUE
	-- Note: heirs must include make_from_json_value in their create clause
	-- and add conversion in their convert clause
    
inherit 
    ANY
    undefine
			is_equal
		end
        
feature {NONE} -- Initialization

	make_from_json_value (jv: JSON_VALUE)
		deferred
		end

feature -- Conversion

	to_json_value: JSON_VALUE
		deferred
		end

feature  -- Static conversion

	new_from_json_value (jv: JSON_VALUE): like Current
		-- A static factory of things like {Current} that can be called like {Current}.new_from_json_value()
		-- Note: This is deferred because we cannot create instances of deferred class
	deferred
	end

	new_to_json_value (me: like Current): JSON_VALUE
		-- A static factory of things like {Current} that can be called like {Current}.new_from_json_value()
	do
        Result := me.to_json_value
	end


end
