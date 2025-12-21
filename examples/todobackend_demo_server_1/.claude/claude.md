# Todo-Backend Demo Server Commands

## Compile the Server

### Fast Compile
```bash
ec -batch -config ./todobackend_demo_server.ecf -target todobackend_demo_server_standalone -c_compile -stop
```

### Clean Compile (do every 5 or so fast compiles)
```bash
ec -batch -clean -config ./todobackend_demo_server.ecf -target todobackend_demo_server_standalone -c_compile -stop
```

## Restart the Server

Kill any existing server and start fresh:
```bash
lsof -ti:8080 | xargs --no-run-if-empty kill -9 && sleep 20 && ./EIFGENs/todobackend_demo_server_standalone/W_code/todobackend_demo_server > /tmp/eiffel_demo_server.lg 2>&1 &
```

**Note:** The 20-second sleep ensures the port is fully released before restarting.

## Run Tests

### Bash Test Suite
```bash
./test_todo_backend.sh http://localhost:8080/todos/
```

### Browser Test Suite
Open in browser:
```
file:///home/agarciafdz/daily/2510oct21/third_party/go-todo-app/test/client/todo-backend-js-spec/index.html?http://localhost:8080/todos/
```

## Verify Server with cURL

### Check CORS Headers
```bash
curl -i -X OPTIONS http://localhost:8080/todos/ \
  -H "Origin: http://example.com" \
  -H "Access-Control-Request-Method: GET"
```

Expected headers:
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Headers: Content-Type, Accept, Origin, X-Requested-With`
- `Access-Control-Allow-Methods: GET, POST, PUT, DELETE, PATCH, OPTIONS`

### GET All Todos
```bash
curl -s -X GET http://localhost:8080/todos/ | jq .
```

### POST New Todo
```bash
curl -s -X POST http://localhost:8080/todos/ \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Todo","completed":false}' | jq .
```

### PATCH Update Todo
```bash
curl -s -X PATCH http://localhost:8080/todos/0 \
  -H "Content-Type: application/json" \
  -d '{"completed":true}' | jq .
```

### DELETE Todo
```bash
curl -s -X DELETE http://localhost:8080/todos/0
```

## Check Server Logs

View real-time server output:
```bash
tail -f /tmp/eiffel_demo_server.lg
```

## Server Configuration

- **Port:** 8080
- **Max Concurrent Connections:** 90
- **Endpoint:** `/todos{/id}`
  - Collection: `http://localhost:8080/todos/`
  - Individual: `http://localhost:8080/todos/{id}`
