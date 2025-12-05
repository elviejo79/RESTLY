note
    description: "SCOOP-friendly JSON object with separate import"
class
    JSON_OBJECT

inherit
   EJSON_JSON_OBJECT

create
    make,
    make_empty,
    make_from_string,      -- handy local factory
    make_from_separate     -- your SCOOP import

feature {NONE} -- Initialization

    make_from_string (s: READABLE_STRING_8)
            -- Initialize Current from JSON text `s`.
        local
            p: JSON_PARSER
        do
            create p.make_with_string (s)
            p.parse_content
           check attached {EJSON_JSON_OBJECT} p.parsed_json_value as jo then
                       make  -- Initialize inherited attributes first
                load_from_parent(jo)
            end
        end

    make_from_separate (other: separate JSON_OBJECT)
            -- Initialize Current by deep-importing `other` from another processor.
        local
            s_sep: separate READABLE_STRING_8
            s: STRING
        do
            -- Prefer a proper JSON representation over `out`.
            -- Most eJSON builds expose `representation: STRING` on JSON_VALUE/OBJECT.
            -- If yours doesn't, fall back to `out` (less ideal).
            s_sep := other.representation
            create s.make_from_separate (s_sep)   -- copy separate string locally
            make_from_string (s)                  -- parse locally; initialize Current
        end

feature {NONE} -- Helpers

    load_from_parent (src: EJSON_JSON_OBJECT)
            -- Populate Current with all pairs from `src`.
        do
            wipe_out
            across src as c loop
                -- deep_twin for safety if values are shared elsewhere
                put (c.item.deep_twin, c.key)
            end
        end
end
