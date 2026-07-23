note
	description: "[
		Article store: hash table keyed by a slug minted from the
		article's title (RealWorld addresses articles by slug).
	]"

class
	ARTICLE_STORE

inherit
	RESOURCE_HASH_TABLE [STRING, JSON_OBJECT]

	RESTLY_POSTABLE [STRING, JSON_OBJECT]

create
	make

feature {NONE} -- Key minting

	fresh_key (a_v: JSON_OBJECT): STRING
			-- <Precursor>: slug from `a_v`'s "title", uniquified if taken.
		do
			Result := slugify (title_of (a_v))
			from
			until
				not has_key (Result)
			loop
				Result := Result + "-" + (table.count + 1).out
			end
		end

	title_of (a_v: JSON_OBJECT): STRING
			-- "title" field of `a_v`, or "untitled".
		do
			if attached {JSON_STRING} a_v ["title"] as l_title then
				Result := l_title.unescaped_string_8
			else
				Result := "untitled"
			end
		end

	slugify (a_title: READABLE_STRING_8): STRING
			-- Lowercase; runs of non-alphanumerics become single dashes.
		local
			i: INTEGER
			c: CHARACTER_8
		do
			create Result.make (a_title.count)
			from
				i := 1
			until
				i > a_title.count
			loop
				c := a_title [i].as_lower
				if c.is_alpha or c.is_digit then
					Result.extend (c)
				elseif not Result.is_empty and then Result [Result.count] /= '-' then
					Result.extend ('-')
				end
				i := i + 1
			end
			Result.prune_all_trailing ('-')
			if Result.is_empty then
				Result := "untitled"
			end
		end

end
