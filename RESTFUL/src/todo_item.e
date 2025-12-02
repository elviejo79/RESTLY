note
	description: "Todo item with custom equality based only on text and completed fields"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TODO_ITEM

inherit
	JSON_OBJECT
		redefine
			is_equal
		end

create
	make,
	make_empty,
	make_from_string,
	make_from_separate

feature -- Comparison

	is_equal (other: like Current): BOOLEAN
			-- Is `other' equal to Current based on text and completed fields only?
		local
			my_text, other_text: detachable JSON_STRING
			my_completed, other_completed: detachable JSON_BOOLEAN
		do
			-- Compare text field
			if attached {JSON_STRING} item ("text") as mt then
				my_text := mt
			end
			if attached {JSON_STRING} other.item ("text") as ot then
				other_text := ot
			end

			-- Compare completed field
			if attached {JSON_BOOLEAN} item ("completed") as mc then
				my_completed := mc
			end
			if attached {JSON_BOOLEAN} other.item ("completed") as oc then
				other_completed := oc
			end

			-- Both must have same text
			if attached my_text and attached other_text then
				Result := my_text.item ~ other_text.item
			elseif not attached my_text and not attached other_text then
				Result := True
			else
				Result := False
			end

			-- And same completed status
			if Result then
				if attached my_completed and attached other_completed then
					Result := my_completed.item = other_completed.item
				elseif not attached my_completed and not attached other_completed then
					Result := Result and True
				else
					Result := False
				end
			end
		end

end
