# Deep-Dive Tutorial: URL Dispatching and Routing in the Eiffel Web Framework (EWF)

URL dispatching (or routing) is a core requirement of modern web applications.
It decouples incoming HTTP request paths from the specific execution logic, allowing you to build clean, RESTful APIs and maintainable web services.

In the Eiffel Web Framework (EWF), routing is handled by `WSF_ROUTED_EXECUTION` and its companion mapping helpers.
This guide walks you through setting up a complete, router-capable EWF application, creating exact match and dynamic template routes, extracting URL parameters safely using Eiffel's type system, and responding to the client.

> Verified against the EWF library bundled with EiffelStudio 25.12
> (`$ISE_LIBRARY/contrib/library/web/framework/ewf`).

---

## 1. Architectural Concepts of EWF Routing

Before diving into code, it is important to understand the components of EWF's routing subsystem.
Modern EWF splits an application into two classes:

1. **The Service (launcher)**: Inherits `WSF_DEFAULT_SERVICE [G]`, a generic class whose parameter `G` is your execution class (`G -> WSF_EXECUTION create make end`).
It configures the connector (port, base URL, verbosity) and launches the server loop.
2. **The Routed Execution (`WSF_ROUTED_EXECUTION`)**: One instance is created per incoming request.
It owns the router, wires it up during `initialize`, and dispatches the request.
You implement the deferred `setup_router`.
3. **The Router Engine (`WSF_ROUTER`)**: The underlying registry that tracks rules, maps paths, filters requests by HTTP verbs (GET, POST, PUT, DELETE), and evaluates incoming requests against the table.
4. **The Mapping Strategy**: EWF provides three native ways to match a request path:
* **Exact URI Mapping**: Direct string equality check (e.g., `/contact` exactly) — `router/support/uri`.
* **URI Template Mapping**: Parameterized pattern matching (e.g., `/user/{name}` or `/blog/{year}/{month}`) — `router/support/uri_template`.
* **Starts-With (Prefix) Mapping**: Matches any URL starting with a designated sequence (useful for static asset directories like `/assets/`) — `router/support/starts_with`.

The convenience features `map_uri` and `map_uri_template` are not on `WSF_ROUTED_EXECUTION` itself.
They come from the mixins `WSF_ROUTED_URI_HELPER` and `WSF_ROUTED_URI_TEMPLATE_HELPER`, which you inherit alongside it.

---

## 2. Step-by-Step Implementation

### Step 1: Design the Application Architecture

The launcher class inherits `WSF_DEFAULT_SERVICE [APPLICATION_EXECUTION]` and starts the server.
All request handling lives in the execution class.

```eiffel
class
    APPLICATION

inherit
    WSF_DEFAULT_SERVICE [APPLICATION_EXECUTION]
        -- Standard server loop; one APPLICATION_EXECUTION is created per request

create
    make

feature {NONE} -- Initialization

    make
        do
            set_service_option ("port", 8080)
            make_and_launch
        end

end
```

### Step 2: Implement the Routed Execution

`WSF_ROUTED_EXECUTION.initialize` already calls `initialize_router`, which creates the router and then calls your deferred `setup_router`.
You do not redefine `initialize` yourself — you only implement `setup_router`.

```eiffel
class
    APPLICATION_EXECUTION

inherit
    WSF_ROUTED_EXECUTION
        -- Router lifecycle: initialize -> initialize_router -> setup_router

    WSF_ROUTED_URI_HELPER
        -- Provides map_uri

    WSF_ROUTED_URI_TEMPLATE_HELPER
        -- Provides map_uri_template

create
    make

feature {NONE} -- Routing

    setup_router
            -- Register mappings between paths/templates and handlers.
        do
            -- Route definitions will reside here
        end

end
```

### Step 3: Configure Mapping and HTTP Method Filters

Inside `setup_router`, you map patterns to designated handler objects.
The third argument of `map_uri` / `map_uri_template` is a `detachable WSF_REQUEST_METHODS` verb filter — pass `Void` to accept any method, or one of the router's predefined collections:

* `router.methods_get`
* `router.methods_post`
* `router.methods_put`
* `router.methods_delete`
* (also combinations such as `router.methods_get_post` or `router.methods_head_get`)

```eiffel
    setup_router
            -- Register mappings between paths/templates and handlers.
        local
            l_contact_handler: CONTACT_HANDLER
            l_user_handler: USER_HANDLER
        do
            -- 1. Exact Mapping (matches exactly "/contact", any HTTP method)
            create l_contact_handler
            map_uri ("/contact", l_contact_handler, Void)

            -- 2. Dynamic Template Mapping (GET requests only)
            create l_user_handler
            map_uri_template ("/user/{name}", l_user_handler, router.methods_get)

            -- 3. Dynamic Template Mapping (POST requests only)
            -- Useful for assigning separate processing handlers to the exact same URL pattern
            -- map_uri_template ("/user/{name}", l_user_update_handler, router.methods_post)
        end
```

### Step 4: Handle Unmatched Paths (404 Fallback)

If an incoming request does not trigger any of your registered mapping definitions, the framework invokes `execute_default`.
Its inherited implementation sends a `WSF_DEFAULT_ROUTER_RESPONSE` listing the available routes.
Redefine it (add `redefine execute_default end` to the `WSF_ROUTED_EXECUTION` inherit clause) to generate a custom 404 page or JSON error object.

```eiffel
feature -- Fallback Execution

    execute_default (req: WSF_REQUEST; res: WSF_RESPONSE)
            -- Triggered automatically when no routing entry matches the request URI.
        local
            l_404_body: STRING
        do
            l_404_body := "<html><head><title>404 Not Found</title></head><body><h1>Error 404: Page Not Found</h1></body></html>"

            res.set_status_code ({HTTP_STATUS_CODE}.not_found)
            res.put_header_line ("Content-Type: text/html")
            res.put_header_line ("Content-Length: " + l_404_body.count.out)
            res.put_string (l_404_body)
        end
```

---

## 3. Deep Dive: Dynamic Parameter Extraction (`/user/{name}`)

When using `map_uri_template`, EWF scans paths for tokens inside curly braces `{}`.
When a match occurs, the framework parses the text occupying that slot and populates it inside the `WSF_REQUEST` path parameters map.

### Void-Safe Extraction Strategy

Because Eiffel strictly enforces void safety, querying a parameter map yields a detachable item: `req.path_parameter (a_name)` returns `detachable WSF_VALUE`.
You use an object test with a type cast (`if attached {WSF_STRING} ... as ...`) to safely narrow it to a string parameter.
`WSF_STRING.value` is a `READABLE_STRING_32`; convert it to UTF-8 with `{UTF_CONVERTER}` before splicing it into a `STRING_8` payload.

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
            if attached {WSF_STRING} req.path_parameter ("name") as p_name then
                -- `value' is READABLE_STRING_32; encode it as UTF-8 for the response body
                l_user_name := {UTF_CONVERTER}.utf_32_string_to_utf_8_string_8 (p_name.value)
            else
                -- Fallback assignment if the parameter is missing or not a string
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
            res.set_status_code ({HTTP_STATUS_CODE}.ok)
            res.put_header_line ("Content-Type: text/html; charset=utf-8")
            res.put_header_line ("Content-Length: " + l_html.count.out)
            res.put_string (l_html)
        end

end
```

> Shortcut: `req.string_item ("name")` returns `detachable READABLE_STRING_32` directly, searching form, query, and path parameters in that order.

---

## 4. Function-Style Handlers: Returning a `WSF_RESPONSE_MESSAGE`

Writing to `res` imperatively (status, headers, body, in the right order) is error-prone.
EWF offers a function-style alternative: the `*_RESPONSE_HANDLER` family.
Instead of `execute`, you implement a query that *returns* the response as a value:

```eiffel
response (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
```

The base class (`WSF_URI_RESPONSE_HANDLER` for exact paths, `WSF_URI_TEMPLATE_RESPONSE_HANDLER` for templates) implements `execute` for you as `res.send (response (req))`.
Ready-made `WSF_RESPONSE_MESSAGE` descendants such as `WSF_PAGE_RESPONSE` and `WSF_HTML_PAGE_RESPONSE` compute `Content-Length` for you, so the manual header bookkeeping disappears — and there is no risk of a half-written response.

```eiffel
class
    USER_RESPONSE_HANDLER

inherit
    WSF_URI_TEMPLATE_RESPONSE_HANDLER

feature -- Response

    response (req: WSF_REQUEST): WSF_RESPONSE_MESSAGE
            -- JSON payload for "/user/{name}", built as a value.
        local
            l_name: STRING
            l_page: WSF_PAGE_RESPONSE
        do
            if attached {WSF_STRING} req.path_parameter ("name") as p_param then
                l_name := {UTF_CONVERTER}.utf_32_string_to_utf_8_string_8 (p_param.value)
            else
                l_name := "Unknown"
            end

            create l_page.make
            l_page.set_status_code ({HTTP_STATUS_CODE}.ok)
            l_page.header.put_content_type ("application/json")
            l_page.put_string ("{%"username%": %"" + l_name + "%", %"status%": %"active%"}")
            Result := l_page
        end

end
```

Register it with the `_response` mapping variants:

```eiffel
    map_uri_template_response ("/user/{name}", l_user_response_handler, router.methods_get)
```

As with plain handlers, an agent form skips the class entirely — pass any `FUNCTION [WSF_REQUEST, WSF_RESPONSE_MESSAGE]`:

```eiffel
    map_uri_template_response_agent ("/user/{name}", agent user_response, router.methods_get)
```

You can also mix styles: inside a plain `execute (req, res)`, build a message and finish with a single `res.send (msg)` instead of the status/header/body sequence.
Prefer the function style for new code — it respects command-query separation and lets the framework own the transmission.

---

## 5. Complete, Production-Ready Code Blueprint

Below is a complete implementation showing how the launcher, the routed execution, and the handler classes interface seamlessly.

### File: `application.e`

```eiffel
class
    APPLICATION

inherit
    WSF_DEFAULT_SERVICE [APPLICATION_EXECUTION]

create
    make

feature {NONE} -- Initialization

    make
            -- Configure and launch the standalone server.
        do
            set_service_option ("port", 8080)
            make_and_launch
        end

end
```

### File: `application_execution.e`

```eiffel
class
    APPLICATION_EXECUTION

inherit
    WSF_ROUTED_EXECUTION
        redefine
            execute_default
        end

    WSF_ROUTED_URI_HELPER

    WSF_ROUTED_URI_TEMPLATE_HELPER

create
    make

feature {NONE} -- Routing

    setup_router
            -- Define paths and attach their operational targets
        local
            l_contact: CONTACT_HANDLER
            l_user: USER_HANDLER
        do
            -- Map Static Endpoint
            create l_contact
            map_uri ("/contact", l_contact, Void)

            -- Map Parameterized Template Endpoint
            create l_user
            map_uri_template ("/user/{name}", l_user, router.methods_get)
        end

feature -- Custom Default 404 Fallback

    execute_default (req: WSF_REQUEST; res: WSF_RESPONSE)
        local
            l_err: STRING
        do
            l_err := "{%"error%": %"Resource path not found%"}"
            res.set_status_code ({HTTP_STATUS_CODE}.not_found)
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

            res.set_status_code ({HTTP_STATUS_CODE}.ok)
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
            if attached {WSF_STRING} req.path_parameter ("name") as p_param then
                l_name := {UTF_CONVERTER}.utf_32_string_to_utf_8_string_8 (p_param.value)
            else
                l_name := "Unknown"
            end

            l_response := "{%"username%": %"" + l_name + "%", %"status%": %"active%"}"

            res.set_status_code ({HTTP_STATUS_CODE}.ok)
            res.put_header_line ("Content-Type: application/json")
            res.put_header_line ("Content-Length: " + l_response.count.out)
            res.put_string (l_response)
        end

end
```

---

## 6. Summary Check-list & Best Practices

1. **One Execution per Request**: The framework creates a fresh `APPLICATION_EXECUTION` (and therefore runs `setup_router`) for every request.
Keep `setup_router` lightweight; anything expensive (database connections, caches) belongs in shared/once objects, not in handler creation.
2. **Key Consistency**: Ensure that the template string name (e.g., `"/user/{name}"`) exactly matches the extraction literal key string inside your handler block (`req.path_parameter ("name")`).
3. **HTTP Verb Filtering**: Always enforce method restrictions (`router.methods_get`, `router.methods_post`, ...) to protect modify/write handlers from unauthorized `GET` queries.
Pass `Void` only when any method is genuinely acceptable.
4. **Content-Length Header**: Always supply a correct `Content-Length` matching your payload byte count (`payload.count.out`) to ensure compliance with strict HTTP/1.1 parsing clients.

---

## 7. Appendix: The `WSF_*_HANDLER` Catalog (tree × role × usage)

The handler zoo is a small grid in disguise:
- how the path matches :: exact URI, `{x}` template, prefix) ×
- how you produce the response :: implement `execute`, implement `response`, or pass an agent
- plus role mixins :: routing mount, filter, self-documentation.
The tree below is the real inheritance hierarchy (from the actual `inherit` clauses in EWF 25.12).
`[+X]` marks the second parent where multiple inheritance combines a matching branch with a role mixin.
Rows whose first column contains only tree bars (`│`) continue the example of the row above.
Examples run inside `setup_router` unless noted.

| Class (inheritance tree)                                                       | Role                                                                                                          | How you use it                                                                                   |
|--------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| `WSF_HANDLER`                                                                  | Root ancestor: `is_valid_context` / `on_mapped` hooks, no `execute`                                           | never used directly                                                                              |
| `├─ WSF_URI_HANDLER`                                                           | **Exact match**; you implement `execute (req, res)`                                                           | `map_uri ("/contact", create {CONTACT_HANDLER}, Void)`                                           |
| `│  ├─ WSF_URI_AGENT_HANDLER` `[+WSF_EXECUTE_AGENT_HANDLER]`                   | Wraps a `PROCEDURE [WSF_REQUEST, WSF_RESPONSE]`                                                               | `map_uri_agent ("/contact", agent handle_contact, Void)`                                         |
| `│  │  └─ WSF_SELF_DOCUMENTED_URI_AGENT_HANDLER`                               | Agent handler + doc text shown by the default route listing                                                   | `create l_doc.make (agent handle_contact, agent contact_doc)`                                    |
| `│  │`                                                                         |                                                                                                               | `map_uri ("/contact", l_doc, Void)`                                                              |
| `│  ├─ WSF_URI_RESPONSE_HANDLER`                                               | You implement `response (req): WSF_RESPONSE_MESSAGE`                                                          | `map_uri_response ("/contact", create {CONTACT_RESPONSE_HANDLER}, Void)`                         |
| `│  │  └─ WSF_URI_RESPONSE_AGENT_HANDLER`                                      | Wraps a `FUNCTION [WSF_REQUEST, WSF_RESPONSE_MESSAGE]`                                                        | `map_uri_response_agent ("/contact", agent contact_response, Void)`                              |
| `│  ├─ WSF_URI_ROUTING_HANDLER` `[+WSF_ROUTING_HANDLER]`                       | Mounts a nested `WSF_ROUTER` at an exact path                                                                 | `create l_api.make (5)`                                                                          |
| `│  │`                                                                         |                                                                                                               | `-- fill l_api.router with sub-routes`                                                           |
| `│  │`                                                                         |                                                                                                               | `map_uri ("/api", l_api, Void)`                                                                  |
| `│  └─ WSF_URI_FILTER_HANDLER [G]` `[+WSF_FILTER_HANDLER]`                     | Middleware around another handler (pre/post-process)                                                          | inherit it; implement `execute` to wrap, chain via `set_next`                                    |
| `├─ WSF_EXECUTE_HANDLER`                                                       | **Any match**; deferred `execute` base of the agent/response plumbing                                         | base class — inherited, not mapped                                                               |
| `│  ├─ WSF_URI_TEMPLATE_HANDLER`                                               | **Template match** `/user/{name}`; you implement `execute`                                                    | `map_uri_template ("/user/{name}", create {USER_HANDLER}, router.methods_get)`                   |
| `│  │  ├─ WSF_URI_TEMPLATE_AGENT_HANDLER` `[+WSF_EXECUTE_AGENT_HANDLER]`       | Wraps a `PROCEDURE [WSF_REQUEST, WSF_RESPONSE]`                                                               | `map_uri_template_agent ("/user/{name}", agent handle_user, router.methods_get)`                 |
| `│  │  │  └─ WSF_SELF_DOCUMENTED_URI_TEMPLATE_AGENT_HANDLER`                   | Agent handler + doc text for the route listing                                                                | `create l_doc.make (agent handle_user, agent user_doc)`                                          |
| `│  │  │`                                                                      |                                                                                                               | `map_uri_template ("/user/{name}", l_doc, Void)`                                                 |
| `│  │  ├─ WSF_URI_TEMPLATE_RESPONSE_HANDLER` `[+WSF_RESPONSE_HANDLER]`         | You implement `response (req): WSF_RESPONSE_MESSAGE`                                                          | `map_uri_template_response ("/user/{name}", create {USER_RESPONSE_HANDLER}, router.methods_get)` |
| `│  │  │  └─ WSF_URI_TEMPLATE_RESPONSE_AGENT_HANDLER`                          | Wraps a `FUNCTION [WSF_REQUEST, WSF_RESPONSE_MESSAGE]`                                                        | `map_uri_template_response_agent ("/user/{name}", agent user_response, router.methods_get)`      |
| `│  │  ├─ WSF_URI_TEMPLATE_ROUTING_HANDLER` `[+WSF_ROUTING_HANDLER]`           | Mounts a nested router under a template                                                                       | `create l_sub.make (5)`                                                                          |
| `│  │  │`                                                                      |                                                                                                               | `-- fill l_sub.router with sub-routes`                                                           |
| `│  │  │`                                                                      |                                                                                                               | `map_uri_template ("/api/{version}", l_sub, Void)`                                               |
| `│  │  └─ WSF_URI_TEMPLATE_FILTER_HANDLER [G]` `[+WSF_FILTER_HANDLER]`         | Middleware around a template handler                                                                          | inherit it; wrap in `execute`, chain via `set_next`                                              |
| `│  ├─ WSF_EXECUTE_AGENT_HANDLER`                                              | Base `PROCEDURE` wrapper behind every `*_AGENT_HANDLER`                                                       | created for you by `map_*_agent`                                                                 |
| `│  ├─ WSF_EXECUTE_RESPONSE_HANDLER`                                           | Base for `response (req)` handlers without own matching                                                       | base class — inherited, not mapped                                                               |
| `│  │  └─ WSF_EXECUTE_RESPONSE_AGENT_HANDLER`                                  | Base `FUNCTION` wrapper behind `*_RESPONSE_AGENT_HANDLER`                                                     | created for you by `map_*_response_agent`                                                        |
| `│  ├─ WSF_EXECUTE_ROUTING_HANDLER` `[+WSF_ROUTING_HANDLER]`                   | Nested-router mount without own matching                                                                      | rarely used directly                                                                             |
| `│  ├─ WSF_EXECUTE_FILTER_HANDLER [G]` `[+WSF_FILTER_HANDLER]`                 | Filter without own matching                                                                                   | rarely used directly                                                                             |
| `│  └─ WSF_WITH_CONDITION_HANDLER`                                             | Empty deferred marker (no features as of 25.12)                                                               | —                                                                                                |
| `├─ WSF_STARTS_WITH_HANDLER`                                                   | **Prefix match**; you implement `execute`; no `map_*` helper — the handler doubles as its own mapping factory | `router.handle ("/assets", l_handler, router.methods_get)`                                       |
| `│  ├─ WSF_STARTS_WITH_AGENT_HANDLER`                                          | Wraps a `PROCEDURE [WSF_REQUEST, WSF_RESPONSE]`                                                               | `create l_files.make (agent handle_files)`                                                       |
| `│  │`                                                                         |                                                                                                               | `router.handle ("/files", l_files, Void)`                                                        |
| `│  │  └─ WSF_SELF_DOCUMENTED_STARTS_WITH_AGENT_HANDLER`                       | Prefix agent handler + doc text                                                                               | as above, with a doc agent in `make`                                                             |
| `│  ├─ WSF_STARTS_WITH_ROUTING_HANDLER` `[+WSF_ROUTING_HANDLER]`               | Mounts a nested router under a prefix                                                                         | `create l_sub.make (5)`                                                                          |
| `│  │`                                                                         |                                                                                                               | `router.handle ("/api", l_sub, Void)`                                                            |
| `│  ├─ WSF_STARTS_WITH_FILTER_HANDLER [G]` `[+WSF_FILTER_HANDLER]`             | Middleware under a prefix                                                                                     | inherit it; wrap in `execute`, chain via `set_next`                                              |
| `│  ├─ WSF_FILE_SYSTEM_HANDLER` `[+WSF_SELF_DOCUMENTED_HANDLER]`               | Serves static files from a directory                                                                          | `create l_fs.make_with_path ("/var/www")`                                                        |
| `│  │`                                                                         |                                                                                                               | `router.handle ("/assets", l_fs, router.methods_get)`                                            |
| `│  └─ WSF_ROUTER_SELF_DOCUMENTATION_HANDLER` `[+WSF_SELF_DOCUMENTED_HANDLER]` | Serves an HTML/text listing of all registered routes                                                          | `create l_doc.make (router)`                                                                     |
| `│`                                                                            |                                                                                                               | `router.handle ("/doc", l_doc, router.methods_get)`                                              |
| `├─ WSF_RESPONSE_HANDLER`                                                      | Mixin: produce a `WSF_RESPONSE_MESSAGE` value                                                                 | inherited by `*_RESPONSE_HANDLER` classes                                                        |
| `├─ WSF_ROUTING_HANDLER`                                                       | Mixin: owns a nested `WSF_ROUTER` (`make (n)`)                                                                | inherited by `*_ROUTING_HANDLER` classes                                                         |
| `├─ WSF_FILTER_HANDLER [G -> WSF_HANDLER]`                                     | Mixin: handler that also filters (`set_next`)                                                                 | inherited by `*_FILTER_HANDLER` classes                                                          |
| `└─ WSF_HANDLER_FILTER_WRAPPER`                                                | Adapter: any handler → filter chain                                                                           | wrap an existing handler in middleware chains                                                    |

(`WSF_SELF_DOCUMENTED_HANDLER` and `WSF_SELF_DOCUMENTED_AGENT_HANDLER` are standalone documentation mixins, not `WSF_HANDLER` descendants.)

Two quirks the tree exposes:

* The hierarchy is asymmetric: `WSF_URI_TEMPLATE_HANDLER` descends from `WSF_EXECUTE_HANDLER`, but `WSF_URI_HANDLER` and `WSF_STARTS_WITH_HANDLER` hang directly off `WSF_HANDLER`.
Historical accretion, not design.
* `WSF_URI_RESPONSE_HANDLER` does *not* inherit the `WSF_RESPONSE_HANDLER` mixin (its template twin does) — it re-declares `response` itself.
Same contract, inconsistent plumbing.

**Practical takeaway**: you hand-write only four of these — `WSF_URI_HANDLER`, `WSF_URI_TEMPLATE_HANDLER`, and their `_RESPONSE_` twins.
The agent variants are instantiated for you by the `map_*_agent` helpers; routing/filter/self-documented classes are plumbing for sub-router mounts, middleware, and route documentation.
