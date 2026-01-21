note
	description: "Summary description for {TODO_ITEM}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TODO_ITEM

inherit
   CONVERTIBLE_WITH_JSON
      redefine
         to_json_object
      end

   PATCHABLE
      redefine
         make_from_patch
      end
   
create
	make_empty,
	make_from_patch,
	make_from_json_object,
	make_from_json_value

convert
	make_from_json_object({JSON_OBJECT}),
	to_json_object:{JSON_OBJECT},
	make_from_json_value({JSON_VALUE}),
	to_json_value:{JSON_VALUE}


feature -- fields

   key: detachable PATH assign set_key

      set_key(v: detachable PATH)
      do
      check attached v then
         key := v
      end
      end
      
title: STRING
completed: BOOLEAN
order: INTEGER

feature
	make_empty
	do
		title := ""
		completed := false
		order := 0
	end

feature -- PATCHABLE
	Patch_ds : TUPLE[title: detachable STRING; completed: detachable BOOLEAN_REF; order: detachable INTEGER_REF]
	do
		Result := [Void, Void, Void]
	end

	make_from_patch(a_patch: like Patch_ds)
	require else
		title_is_required_field: attached a_patch.title
	do
		make_empty
		patch(a_patch)
	end

	patch(a_patch: like Patch_ds)
	do
		if attached a_patch.title as l_title then
			title := l_title
		end
		if attached a_patch.completed as l_completed then
			completed := l_completed.item
		end
		if attached a_patch.order as l_order then
			order := l_order.item
		end
	end

feature -- convertible_with_json
	make_from_json_object(a_jo:JSON_OBJECT)
	do
		make_empty
		patch(tuple_from_json_object(a_jo))
	end

	to_json_object: JSON_OBJECT
      do
         create Result.make_with_capacity(5)
         if attached key as l_key then
            Result.put_string(l_key.out, "key")
            Result.put_string("http://localhost:8080/todos/"+l_key.out, "url")
         end
         Result.put_string(title, "title")
         Result.put_boolean(completed, "completed")
         Result.put_integer(order, "order")
         
      end

	tuple_from_json_object(a_jo:JSON_OBJECT): like Patch_ds
	local
		l_completed_ref: detachable BOOLEAN_REF
		l_order_ref: detachable INTEGER_REF
	do
		if attached {JSON_BOOLEAN} a_jo.item("completed") as l_val and then attached {BOOLEAN} l_val.item as l_r then
			create l_completed_ref
			l_completed_ref.set_item(l_r)
		end
		if attached {JSON_NUMBER} a_jo.item("order") as l_val then
			create l_order_ref
			l_order_ref.set_item(l_val.item.to_integer_64.to_integer)
		end
		Result := [
			(if attached {JSON_STRING} a_jo.item("title") as l_val and then attached {STRING} l_val.item as l_r then l_r else Void end),
			l_completed_ref,
			l_order_ref
		]
	end


      
feature -- convertible_with_json_value
	make_from_json_value(a_jv:JSON_VALUE)
		-- JSON_VALUE is just an ancestor to a JSON_OBJECT
		-- so I need this method just for the convert clasue to do the right thing when given a JSON_VALUE
	do
		check attached {JSON_OBJECT} a_jv as l_jo then
			make_from_json_object(l_jo)
		end
	end

	to_json_value:JSON_VALUE
	do
   Result := to_json_object
	end
end
