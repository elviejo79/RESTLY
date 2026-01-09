# Next Steps to Run CLI Tests

## Summary of Work Done

### 1. Studied the Test Client Directory
Located at: `/home/agarciafdz/daily/2510oct21/third_party/go-todo-app/test/client`

The directory contains:
- **client.test.js**: Command-line test runner using Mocha + jsdom
- **todo-backend-js-spec/**: Browser-based test suite with Mocha/Chai
- **specs.js**: Core API specification tests (16 test cases)

The test suite validates Todo Backend API implementations across 4 areas:
1. Pre-requisites (CORS, server accessibility)
2. Creating Todos (POST to root)
3. Managing Todos (GET/PATCH/DELETE by URL)
4. Order Tracking (optional order field)

### 2. Commands to run tests

Command used:
```bash
cd /home/agarciafdz/daily/2510oct21/third_party/go-todo-app/test/client
TEST_SERVER_URL=http://localhost:8080/todos/ npm test
```

## Test Manually

```bash
# Create a todo
curl -X POST http://localhost:8080/todos/ -H "Content-Type: application/json" -d '{"title":"test"}'

# List all todos
curl http://localhost:8080/todos/

# Get specific todo (use id from POST response)
curl http://localhost:8080/todos/1

# Update a todo
curl -X PATCH http://localhost:8080/todos/1 -H "Content-Type: application/json" -d '{"completed":true}'
```

### Step 2: Run Tests After Fixes

```bash
cd /home/agarciafdz/daily/2510oct21/examples/todobackend_demo_server_1

# Restart server with updated code
lsof -ti:8080 | xargs --no-run-if-empty kill -9 && sleep 20 && ec -batch -config ./todobackend_demo_server.ecf -target todobackend_demo_server_standalone -c_compile -stop && nohup ./EIFGENs/todobackend_demo_server_standalone/W_code/todobackend_demo_server > /tmp/todobackend_server.log 2>&1 &

# Wait for server to start
sleep 3

# Run test suite
cd /home/agarciafdz/daily/2510oct21/third_party/go-todo-app/test/client
TEST_SERVER_URL=http://localhost:8080/todos/ npm test
```


## Notes

- The test suite is the canonical Todo Backend specification from TodoBackend.com
- These tests validate full CRUD operations, CORS headers, and persistence
- Once passing, the implementation will be compliant with the Todo Backend spec
