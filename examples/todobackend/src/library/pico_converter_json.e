deferred class PICO_CONVERTER_JSON[S -> {CONVERTIBLE_WITH_JSON, PATCHABLE} create make_empty, make_from_json_object end]
inherit
	PICO_CONVERTER[JSON_OBJECT, S]

feature -- Patch descriptor

	Patch_ds: JSON_OBJECT
		do
			create Result.make_empty
		end

feature -- Converters

	to_representation (a_s: S): JSON_OBJECT
		do
			Result := a_s.to_json_object
		end

	to_storage (a_r: JSON_OBJECT): S
		do
			create Result.make_from_json_object (a_r)
		end

	to_storage_patch (a_representation_patch: like Patch_ds): like backend.patch_ds
		local
			l_s: S
		do
			create l_s.make_empty
			Result := l_s.tuple_from_json_object (a_representation_patch)
		end

end
   
