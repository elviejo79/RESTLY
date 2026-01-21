deferred class PATCHABLE

feature {NONE}-- should be in the class that implemnts this
      make_empty
      deferred
      end
         
feature -- PATCHABLE
Patch_ds : TUPLE
      deferred
      end

   make_from_patch(a_patch: like Patch_ds)
	do
		make_empty
		patch(a_patch)
	end

	patch(a_patch: like Patch_ds)
      deferred
      end
end
