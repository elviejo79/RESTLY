class TODO_JSON_DECORATOR

inherit
PICO_CONVERTER_JSON[TODO_ITEM]
      redefine
      item
      end

feature -- state
base_url : STRING

feature -- Initialize
make(a_base_url: like base_url)
      do
      base_url := a_base_url
      end
feature --converters

to_storage_patch(a_patch_jo: JSON_OBJECT): like backend.patch_ds
      do
      Result := {TODO_ITEM}.tuple_from_json_object(a_patch_jo)
      end

feature -- Queries
item alias "/" (a_key: PATH):JSON_OBJECT assign force
      do
      Result := Precursor(a_key)
         
         Result.put_string(base_url+"/"+ a_key.to_string_8, "url")
      end
end
