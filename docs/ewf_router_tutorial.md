# Deep-Dive Tutorial: URL Dispatching and Routing in the Eiffel Web Framework (EWF)

URL dispatching (or routing) is a core requirement of modern web applications. It decouples incoming HTTP request paths from the specific execution logic, allowing you to build clean, RESTful APIs and maintainable web services.

In the Eiffel Web Framework (EWF), routing is handled elegantly using the `WSF_ROUTED_SERVICE` and its companion mapping components. This comprehensive guide walks you through setting up a complete, router-capable EWF application, creating exact match and dynamic template routes, extracting URL parameters safely using Eiffel's type system, and responding to the client.

---

## 1. Architectural Concepts of EWF Routing

Before diving into code, it is important to understand the three distinct components of EWF's routing subsystem:

1. **The Routed Service (`WSF_ROUTED_SERVICE`)**: An intersection class (mixin) that infuses your standard application service with a dedicated router instance and Lifecycle hooks (`setup_router`, `initialize_router`).
2. **The Router Engine (`WSF_ROUTER`)**: The underlying registry that tracks rules, maps paths, filters requests by HTTP verbs (GET, POST, PUT, DELETE), and evaluates incoming requests against the table.
3. **The Mapping Strategy**: EWF provides three native ways to match a request path:
* **Exact URI Mapping**: Direct string equality check (e.g., `/contact` exactly).
* **URI Template Mapping**: Parameterized pattern matching (e.g., `/user/{name}` or `/blog/{year}/{month}`).
* **Prefix String Mapping**: Matches any URL starting with a designated sequence (useful for static asset directories like `/assets/`).



---

## 2. Step-by-Step Implementation

### Step 1: Design the Application Architecture

Your central driver class must inherit from `WSF_DEFAULT_SERVICE` (or your chosen server connector execution base) and `WSF_ROUTED_SERVICE` to gain access to the routing framework API.

```eiffel
class
    APPLICATION

inherit
    WSF_DEFAULT_SERVICE
        -- Gives standard web application server loops and environment configurations

    WSF_ROUTED_SERVICE
        -- Injects router capabilities, helpers, and hooks

create
    make

```

### Step 2: Implement Initialization Hooks

When implementing `WSF_ROUTED_SERVICE`, you are required to establish the router infrastructure during initialization and implement the abstract routing setup.

```eiffel
feature {NONE} -- Initialization

    initialize
            -- Initialize the underlying EWF components and the routing engine.
        do
            initialize_router
        end

    setup_router
            -- Register mappings between paths/templates and handlers.
        do
            -- Route definitions will reside here
        end

```

### Step 3: Configure Mapping and HTTP Method Filters

Inside `setup_router`, you map patterns to designated handler objects. You can also specify constraints based on HTTP request methods using predefined router collection features:

* `router.get_request_methods`
* `router.post_request_methods`
* `router.put_request_methods`
* `router.delete_request_methods`

```eiffel
    setup_router
            -- Register mappings between paths/templates and handlers.
        local
            l_contact_handler: CONTACT_HANDLER
            l_user_handler: USER_HANDLER
        do
            -- 1. Exact Mapping (Matches exactly "/contact")
            create l_contact_handler
            map_uri ("/contact", l_contact_handler)

            -- 2. Dynamic Template Mapping (GET request only)
            create l_user_handler
            map_uri_template ("/user/{name}", l_user_handler, router.get_request_methods)

            -- 3. Dynamic Template Mapping (POST request only)
            -- Useful for assigning separate processing handlers to the exact same URL pattern
            -- map_uri_template ("/user/{name}", l_user_update_handler, router.post_request_methods)
        end

```

### Step 4: Handle Unmatched Paths (404 Fallback)

If an incoming request does not trigger any of your registered mapping definitions, the framework invokes `execute_default`. You can redefine this method to generate a custom 404 page or JSON error object.

```eiffel
feature -- Fallback Execution

    execute_default (req: WSF_REQUEST; res: WSF_RESPONSE)
            -- Triggered automatically when no routing entry matches the request URI.
        local
            l_404_body: STRING
        do
            l_404_body := "<html><head><title>404 Not Found</title></head><body><h1>Error 404: Page Not Found</h1></body></html>"

            res.set_status ({HTTP_STATUS_CODE}.not_found)
            res.put_header_line ("Content-Type: text/html")
            res.put_header_line ("Content-Length: " + l_404_body.count.out)
            res.put_string (l_404_body)
        end

```

---

## 3. Deep Dive: Dynamic Parameter Extraction (`/user/{name}`)

When using `map_uri_template`, EWF scans paths for tokens inside curly braces `{}`. When a match occurs, the framework parses the text occupying that slot and populates it inside the `WSF_REQUEST` path parameters map.

### Void-Safe Extraction Strategy

Because Eiffel strictly enforces void safety, querying a parameter map yields a detachable item (`detachable WSF_STRING_PARAMETER`). You must use an assignment attempt check (`if attached ... as ...`) to safely extract, type-cast, and convert the parameter to a standard string.

Here is how you handle the dynamic `{name}` variable inside a custom handler class:

```eiffel
class
    USER_HANDLER

inherit
    WSF_URI_TEMPLATE_HANDLER
        -- Base interface required for handling parameterized URI template matches

feature -- Execution

    execute (req: WSF_REQUEST; res: WSF_RESPONSE)
            -- Processes the HTTP request matching "/user/{name}"
        local
            l_user_name: STRING
            l_html: STRING
        do
            -- Extract the parameter by passing the exact dictionary key string used in the template.
            if attached req.path_parameter ("name") as p_name then
                -- '.string_value' converts the WSF parameter instance into a standard Eiffel STRING
                l_user_name := p_name.string_value
            else
                -- Fallback assignment if the property failed validation or was structural empty
                l_user_name := "Anonymous Guest"
            end

            -- Construct dynamic application data payload
            create l_html.make_empty
            l_html.append ("<!DOCTYPE html>%N")
            l_html.append ("<html>%N<head><title>User Dashboard</title></head>%N")
            l_html.append ("<body>%N")
            l_html.append ("  <h1>User Profile Workspace</h1>%N")
            l_html.append ("  <p>Welcome back, <strong>" + l_user_name + "</strong>!</p>%N")
            l_html.append ("</body>%N</html>")

            -- Dispatch HTTP Response back to client
            res.set_status ({HTTP_STATUS_CODE}.ok)
            res.put_header_line ("Content-Type: text/html; charset=utf-8")
            res.put_header_line ("Content-Length: " + l_html.count.out)
            res.put_string (l_html)
        end

end

```

---

## 4. Complete, Production-Ready Code Blueprint

Below is a complete implementation showing how the application configuration file and its companion handler files interface seamlessly.

### File: `application.e`

```eiffel
class
    APPLICATION

inherit
    WSF_DEFAULT_SERVICE
    WSF_ROUTED_SERVICE

create
    make

feature {NONE} -- Initialization

    initialize
            -- Prepare the service architecture
        do
            initialize_router
        end

    setup_router
            -- Define paths and attach their operational targets
        local
            l_contact: CONTACT_HANDLER
            l_user: USER_HANDLER
        do
            -- Map Static Endpoint
            create l_contact
            map_uri ("/contact", l_contact)

            -- Map Parameterized Template Endpoint
            create l_user
            map_uri_template ("/user/{name}", l_user, router.get_request_methods)
        end

feature -- Custom Default 404 Fallback

    execute_default (req: WSF_REQUEST; res: WSF_RESPONSE)
        local
            l_err: STRING
        do
            l_err := "{"error": "Resource path not found"}"
            res.set_status ({HTTP_STATUS_CODE}.not_found)
            res.put_header_line ("Content-Type: application/json")
            res.put_header_line ("Content-Length: " + l_err.count.out)
            res.put_string (l_err)
        end

end

```

### File: `contact_handler.e`

```eiffel
class
    CONTACT_HANDLER

inherit
    WSF_URI_HANDLER
        -- Simple URI Handler used for exact string path evaluations (no placeholders)

feature -- Execution

    execute (req: WSF_REQUEST; res: WSF_RESPONSE)
        local
            l_response: STRING
        do
            l_response := "<h1>Contact Page</h1><p>Reach out to us at support@example.com</p>"

            res.set_status ({HTTP_STATUS_CODE}.ok)
            res.put_header_line ("Content-Type: text/html")
            res.put_header_line ("Content-Length: " + l_response.count.out)
            res.put_string (l_response)
        end

end

```

### File: `user_handler.e`

```eiffel
class
    USER_HANDLER

inherit
    WSF_URI_TEMPLATE_HANDLER

feature -- Execution

    execute (req: WSF_REQUEST; res: WSF_RESPONSE)
        local
            l_name: STRING
            l_response: STRING
        do
            if attached req.path_parameter ("name") as p_param then
                l_name := p_param.string_value
            else
                l_name := "Unknown"
            end

            l_response := "{"username": "" + l_name + "", "status": "active"}"

            res.set_status ({HTTP_STATUS_CODE}.ok)
            res.put_header_line ("Content-Type: application/json")
            res.put_header_line ("Content-Length: " + l_response.count.out)
            res.put_string (l_response)
        end

end

```

---

## 5. Summary Check-list & Best Practices

1. **Keep Handler Instantiation Clean**: Initialize your concrete operational handler instances inside `setup_router`. Avoid creating new ones per request to conserve memory.
2. **Key Consistency**: Ensure that the template string name (e.g., `"/user/{name}"`) exactly matches the extraction literal key string inside your handler block (`req.path_parameter ("name")`).
3. **HTTP Verb Filtering**: Always enforce method restrictions (`router.get_request_methods`, `router.post_request_methods`) to protect modify/write handlers from unauthorized `GET` queries.
4. **Content-Length Header**: Always supply a correct `Content-Length` matching your payload byte count (`payload.count.out`) to ensure compliance with strict HTTP/1.1 parsing clients.
