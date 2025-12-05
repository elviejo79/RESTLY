note
	description: "GitHub repository data class"
	author: "Agarciafdz and Claude.ai"
	date: "$Date$"
	revision: "$Revision$"

class
	GITHUB_REPOSITORY

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize an empty repository.
		do
			create name.make_empty
			create description.make_empty
			create git_hub_homeurl.make_empty
			create home_page.make_empty
			watchers := 0
			create last_push_utc.make_now
		end

feature -- Access

	name: STRING
			-- Repository name

	description: STRING
			-- Repository description

	git_hub_homeurl: STRING
			-- GitHub URL

	home_page: STRING
			-- Homepage URL

	watchers: INTEGER
			-- Number of watchers

	last_push_utc: DATE_TIME
			-- Last push time in UTC

	last_push: STRING
			-- Get last push time as formatted string
		do
			Result := last_push_utc.formatted_out ("yyyy-mm-dd hh:[0]mi:[0]ss")
		end

feature -- Element Change

	set_name (a_name: STRING)
			-- Set repository name
		do
			name := a_name
		ensure
			name_set: name = a_name
		end

	set_description (a_description: STRING)
			-- Set repository description
		do
			description := a_description
		ensure
			description_set: description = a_description
		end

	set_git_hub_homeurl (a_url: STRING)
			-- Set GitHub URL
		do
			git_hub_homeurl := a_url
		ensure
			git_hub_homeurl_set: git_hub_homeurl = a_url
		end

	set_home_page (a_url: STRING)
			-- Set homepage URL
		do
			home_page := a_url
		ensure
			home_page_set: home_page = a_url
		end

	set_watchers (a_count: INTEGER)
			-- Set watchers count
		require
			a_count_valid: a_count >= 0
		do
			watchers := a_count
		ensure
			watchers_set: watchers = a_count
		end

	set_last_push_utc (a_date: DATE_TIME)
			-- Set last push date
		do
			last_push_utc := a_date
		ensure
			last_push_utc_set: last_push_utc = a_date
		end

feature -- Conversion

	from_json (a_json: STRING): like Current
			-- Create a repository from JSON string
		require
			a_json_not_empty: not a_json.is_empty
		local
			parser: JSON_PARSER
		do
			create Result.make

			create parser.make_with_string (a_json)
			parser.parse_content

			if parser.is_valid and then attached {JSON_OBJECT} parser.parsed_json_value as json_object then
				Result := from_json_object (json_object)
			end
		ensure
			class
		end

	from_json_object (json_object: JSON_OBJECT): like Current
			-- Create a repository from JSON object
		do
			create Result.make

				-- Extract properties from JSON object
			if attached {JSON_STRING} json_object.item ("name") as json_name then
				Result.set_name (json_name.item)
			end

			if attached {JSON_STRING} json_object.item ("description") as json_description then
				Result.set_description (json_description.item)
			end

			if attached {JSON_STRING} json_object.item ("html_url") as json_github_url then
				Result.set_git_hub_homeurl (json_github_url.item)
			end

			if attached {JSON_STRING} json_object.item ("homepage") as json_homepage then
				Result.set_home_page (json_homepage.item)
			end

			if attached {JSON_NUMBER} json_object.item ("watchers_count") as json_watchers then
				Result.set_watchers (json_watchers.item.to_integer)
			end

--			if attached {JSON_STRING} json_object.item ("pushed_at") as json_pushed_at then
--					-- Parse ISO8601 date format
--				Result.set_last_push_utc (parse_iso8601_date (json_pushed_at.item))
--			end
		ensure
			class
		end

	to_json: STRING
			-- Convert repository to JSON string
		local
			json_object: JSON_OBJECT
		do
			create json_object.make

				-- Add properties to JSON object
			json_object.put_string (name, "name")
			json_object.put_string (description, "description")
			json_object.put_string (git_hub_homeurl, "html_url")
			json_object.put_string (home_page, "homepage")
			json_object.put_integer (watchers, "watchers_count")
			json_object.put_string (format_iso8601_date (last_push_utc), "pushed_at")

			Result := json_object.representation
		end

feature {NONE} -- Implementation

	parse_iso8601_date (date_string: STRING): DATE_TIME
			-- Parse ISO8601 date format (e.g. "2023-08-14T12:29:32Z")
		local
			year, month, day, hour, minute, second: INTEGER
		do
				-- Basic parsing (in production code, use a more robust parser)
			if date_string.count >= 19 then
				year := date_string.substring (1, 4).to_integer
				month := date_string.substring (6, 7).to_integer
				day := date_string.substring (9, 10).to_integer
				hour := date_string.substring (12, 13).to_integer
				minute := date_string.substring (15, 16).to_integer
				second := date_string.substring (18, 19).to_integer

				create Result.make_fine (year, month, day, hour, minute, second)
			else
				create Result.make_now
			end
		end

	format_iso8601_date (date_time: DATE_TIME): STRING
			-- Format date as ISO8601 string
		do
			Result := date_time.formatted_out ("yyyy-mm-dd[T]hh:[0]mi:[0]ss[Z]")
		end

end
