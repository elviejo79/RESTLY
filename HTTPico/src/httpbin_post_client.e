note
    description: "HTTP client for sending a POST request to httpbin.io"
    author: "Claude"
    date: "2025-05-16"

class
    HTTPBIN_POST_CLIENT

inherit
    ARGUMENTS

create
    make

feature {NONE} -- Initialization

    make
            -- Send a POST request to httpbin.io/post
        local
            http_client: LIBCURL_HTTP_CLIENT
            response: HTTP_CLIENT_RESPONSE
            post_data: STRING
        do
            create http_client.make

            -- Configure client
            http_client.set_connect_timeout (10)
            http_client.set_timeout (30)

            -- Create POST data (JSON format)
            post_data := "{%"name%":%"Eiffel Test%",%"message%":%"Hello from Eiffel!%"}"

            -- Set headers
            http_client.set_header ("Content-Type", "application/json")

            -- Send the POST request
            response := http_client.post ("https://httpbin.io/post", post_data)

            -- Check and display results
            if response.error_occurred then
                io.error.put_string ("Error: " + response.error_message + "%N")
            else
                io.put_string ("Status code: " + response.status.out + "%N")
                io.put_string ("Response body:%N")
                io.put_string (response.body + "%N")

                -- Parse and display specific parts of the response if needed
                -- This would require JSON parsing which can be added with a library
            end

            -- Clean up
            http_client.close
        end

end -- class HTTPBIN_POST_CLIENT
