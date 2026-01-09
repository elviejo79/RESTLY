class TODO_ITEM

inherit
	ANY
		redefine
			is_equal
		end

create
	make_empty

feature {NONE} -- Initialization

	make_empty
		do
			create title.make_empty
			completed := False
			order := 0
			id := 0
		end

feature -- Access
	id: INTEGER
	title: STRING_32
	completed: BOOLEAN
	order: INTEGER
	url: URI
		attribute
			create Result.make_from_string ("")
		end

feature -- Comparison

	is_equal (other: like Current): BOOLEAN
			-- Is `other' equal to Current based on content?
		do
			Result := id = other.id and then
					  title ~ other.title and then
					  completed = other.completed and then
					  order = other.order and then
					  url.string ~ other.url.string
		end

end
