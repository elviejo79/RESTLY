#!/bin/bash
set -x
#set -euo  pipefail
#IFS=$'\n\t'

# Todo-Backend API Test Suite
# Translated from todo-backend-js-spec

# Configuration
API_ROOT="${1:-http://localhost:3000/todos}"
PASSED=0
FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    echo -e "  ${RED}$2${NC}"
    ((FAILED++))
}

section() {
    echo -e "\n${YELLOW}$1${NC}"
}

# HTTP helper functions
get() {
    curl -s -X GET "$1" \
        -H "Content-Type: application/json" \
        -w "\n%{http_code}"
}

post() {
    curl -s -X POST "$1" \
        -H "Content-Type: application/json" \
        -d "$2" \
        -w "\n%{http_code}"
}

patch() {
    curl -s -X PATCH "$1" \
        -H "Content-Type: application/json" \
        -d "$2" \
        -w "\n%{http_code}"
}

delete() {
    curl -s -X DELETE "$1" \
        -H "Content-Type: application/json" \
        -w "\n%{http_code}"
}

options() {
    curl -s -X OPTIONS "$1" \
        -H "Content-Type: application/json" \
        -w "\n%{http_code}"
}

# Extract HTTP status code (last line)
get_status() {
    echo "$1" | tail -n 1
}

# Extract response body (all but last line)
get_body() {
    echo "$1" | sed '$d'
}

# JSON helpers (using grep/sed for basic parsing, jq would be better)
json_value() {
    echo "$1" | grep -o "\"$2\":[^,}]*" | sed "s/\"$2\"://g" | tr -d '"' | tr -d ' '
}

json_array_length() {
    # Simple array length counter
    echo "$1" | grep -o "{" | wc -l
}

# Start tests
echo "======================================"
echo "Todo-Backend API Test Suite"
echo "Testing: $API_ROOT"
echo "======================================"

# PRE-REQUISITES
section "Pre-requisites"

# Test 1: API root responds to GET
RESPONSE=$(get "$API_ROOT")
STATUS=$(get_status "$RESPONSE")
if [[ "$STATUS" == "200" ]]; then
    pass "the api root responds to a GET (server is up and accessible, CORS headers are set up)"
else
    fail "the api root responds to a GET" "Expected status 200, got $STATUS"
fi

# Test 2: API root responds to POST with the todo
RESPONSE=$(post "$API_ROOT" '{"title":"a todo"}')
STATUS=$(get_status "$RESPONSE")
BODY=$(get_body "$RESPONSE")
TITLE=$(json_value "$BODY" "title")
if [[ "$STATUS" == "201" || "$STATUS" == "200" ]] && [[ "$TITLE" == "atodo" ]]; then
    pass "the api root responds to a POST with the todo which was posted to it"
else
    fail "the api root responds to a POST" "Expected title 'a todo', got '$TITLE' (status: $STATUS)"
fi

# Test 3: API root responds successfully to DELETE
RESPONSE=$(delete "$API_ROOT")
STATUS=$(get_status "$RESPONSE")
if [[ "$STATUS" == "200" || "$STATUS" == "204" ]]; then
    pass "the api root responds successfully to a DELETE"
else
    fail "the api root responds successfully to a DELETE" "Expected status 200/204, got $STATUS"
fi

# Test 4: After DELETE, GET returns empty array
RESPONSE=$(get "$API_ROOT")
BODY=$(get_body "$RESPONSE")
if [[ "$BODY" == "[]" ]]; then
    pass "after a DELETE the api root responds to a GET with a JSON representation of an empty array"
else
    fail "after a DELETE, GET returns empty array" "Expected '[]', got '$BODY'"
fi

# STORING NEW TODOS
section "Storing new todos by posting to the root url"

# Clean slate
delete "$API_ROOT" > /dev/null

# Test 5: Adds a new todo to the list
RESPONSE=$(post "$API_ROOT" '{"title":"walk the dog"}')
RESPONSE=$(get "$API_ROOT")
BODY=$(get_body "$RESPONSE")
COUNT=$(json_array_length "$BODY")
TITLE=$(json_value "$BODY" "title")
if [[ "$COUNT" == "1" ]] && [[ "$TITLE" == "walkthedog" ]]; then
    pass "adds a new todo to the list of todos at the root url"
else
    fail "adds a new todo to the list" "Expected 1 todo with title 'walk the dog'"
fi

# Clean slate
delete "$API_ROOT" > /dev/null

# Test 6: Sets up new todo as initially not completed
RESPONSE=$(post "$API_ROOT" '{"title":"blah"}')
BODY=$(get_body "$RESPONSE")
COMPLETED=$(json_value "$BODY" "completed")
if [[ "$COMPLETED" == "false" ]]; then
    pass "sets up a new todo as initially not completed"
else
    fail "sets up new todo as not completed" "Expected completed=false, got '$COMPLETED'"
fi

# Test 7: Each new todo has a url
delete "$API_ROOT" > /dev/null
RESPONSE=$(post "$API_ROOT" '{"title":"blah"}')
BODY=$(get_body "$RESPONSE")
URL=$(json_value "$BODY" "url")
if [[ -n "$URL" ]] && [[ "$URL" == http* ]]; then
    pass "each new todo has a url"
else
    fail "each new todo has a url" "Expected URL starting with http, got '$URL'"
fi

# Test 8: URL returns the todo
delete "$API_ROOT" > /dev/null
RESPONSE=$(post "$API_ROOT" '{"title":"my todo"}')
BODY=$(get_body "$RESPONSE")
TODO_URL=$(json_value "$BODY" "url")
if [[ -n "$TODO_URL" ]]; then
    RESPONSE=$(get "$TODO_URL")
    BODY=$(get_body "$RESPONSE")
    TITLE=$(json_value "$BODY" "title")
    if [[ "$TITLE" == "mytodo" ]]; then
        pass "each new todo has a url, which returns a todo"
    else
        fail "URL returns the todo" "Expected title 'my todo', got '$TITLE'"
    fi
else
    fail "URL returns the todo" "No URL found in created todo"
fi

# WORKING WITH EXISTING TODO
section "Working with an existing todo"

# Clean slate
delete "$API_ROOT" > /dev/null

# Test 9: Can navigate from list to individual todo
RESPONSE=$(post "$API_ROOT" '{"title":"todo the first"}')
RESPONSE=$(post "$API_ROOT" '{"title":"todo the second"}')
RESPONSE=$(get "$API_ROOT")
BODY=$(get_body "$RESPONSE")
# Extract first URL (this is simplified, real parsing would be better)
FIRST_URL=$(echo "$BODY" | grep -o '"url":"[^"]*' | head -n 1 | sed 's/"url":"//')
if [[ -n "$FIRST_URL" ]]; then
    RESPONSE=$(get "$FIRST_URL")
    BODY=$(get_body "$RESPONSE")
    TITLE=$(json_value "$BODY" "title")
    if [[ -n "$TITLE" ]]; then
        pass "can navigate from a list of todos to an individual todo via urls"
    else
        fail "navigate to individual todo" "Could not get title from individual todo"
    fi
else
    fail "navigate to individual todo" "Could not extract URL from todo list"
fi

# Clean slate
delete "$API_ROOT" > /dev/null

# Test 10: Can change title by PATCHing
RESPONSE=$(post "$API_ROOT" '{"title":"initial title"}')
BODY=$(get_body "$RESPONSE")
TODO_URL=$(json_value "$BODY" "url")
if [[ -n "$TODO_URL" ]]; then
    RESPONSE=$(patch "$TODO_URL" '{"title":"bathe the cat"}')
    BODY=$(get_body "$RESPONSE")
    TITLE=$(json_value "$BODY" "title")
    if [[ "$TITLE" == "bathethecat" ]]; then
        pass "can change the todo's title by PATCHing to the todo's url"
    else
        fail "change title by PATCH" "Expected 'bathe the cat', got '$TITLE'"
    fi
else
    fail "change title by PATCH" "Could not get URL from created todo"
fi

# Clean slate
delete "$API_ROOT" > /dev/null

# Test 11: Can change completedness by PATCHing
RESPONSE=$(post "$API_ROOT" '{"title":"blah"}')
BODY=$(get_body "$RESPONSE")
TODO_URL=$(json_value "$BODY" "url")
if [[ -n "$TODO_URL" ]]; then
    RESPONSE=$(patch "$TODO_URL" '{"completed":true}')
    BODY=$(get_body "$RESPONSE")
    COMPLETED=$(json_value "$BODY" "completed")
    if [[ "$COMPLETED" == "true" ]]; then
        pass "can change the todo's completedness by PATCHing to the todo's url"
    else
        fail "change completedness by PATCH" "Expected completed=true, got '$COMPLETED'"
    fi
else
    fail "change completedness by PATCH" "Could not get URL from created todo"
fi

# Clean slate
delete "$API_ROOT" > /dev/null

# Test 12: Changes are persisted
RESPONSE=$(post "$API_ROOT" '{"title":"original"}')
BODY=$(get_body "$RESPONSE")
TODO_URL=$(json_value "$BODY" "url")
if [[ -n "$TODO_URL" ]]; then
    RESPONSE=$(patch "$TODO_URL" '{"title":"changed title","completed":true}')
    # Verify by re-fetching
    RESPONSE=$(get "$TODO_URL")
    BODY=$(get_body "$RESPONSE")
    TITLE=$(json_value "$BODY" "title")
    COMPLETED=$(json_value "$BODY" "completed")
    if [[ "$TITLE" == "changedtitle" ]] && [[ "$COMPLETED" == "true" ]]; then
        pass "changes to a todo are persisted and show up when re-fetching the todo"
    else
        fail "changes are persisted" "Expected title='changed title' completed=true, got title='$TITLE' completed='$COMPLETED'"
    fi
else
    fail "changes are persisted" "Could not get URL from created todo"
fi

# Clean slate
delete "$API_ROOT" > /dev/null

# Test 13: Can delete a todo
RESPONSE=$(post "$API_ROOT" '{"title":"to be deleted"}')
BODY=$(get_body "$RESPONSE")
TODO_URL=$(json_value "$BODY" "url")
if [[ -n "$TODO_URL" ]]; then
    RESPONSE=$(delete "$TODO_URL")
    RESPONSE=$(get "$API_ROOT")
    BODY=$(get_body "$RESPONSE")
    if [[ "$BODY" == "[]" ]]; then
        pass "can delete a todo making a DELETE request to the todo's url"
    else
        fail "delete a todo" "Expected empty list after delete, got '$BODY'"
    fi
else
    fail "delete a todo" "Could not get URL from created todo"
fi

# TRACKING TODO ORDER
section "Tracking todo order"

# Clean slate
delete "$API_ROOT" > /dev/null

# Test 14: Can create todo with order field
RESPONSE=$(post "$API_ROOT" '{"title":"blah","order":523}')
BODY=$(get_body "$RESPONSE")
ORDER=$(json_value "$BODY" "order")
if [[ "$ORDER" == "523" ]]; then
    pass "can create a todo with an order field"
else
    fail "create todo with order" "Expected order=523, got '$ORDER'"
fi

# Clean slate
delete "$API_ROOT" > /dev/null

# Test 15: Can PATCH to change order
RESPONSE=$(post "$API_ROOT" '{"title":"blah","order":10}')
BODY=$(get_body "$RESPONSE")
TODO_URL=$(json_value "$BODY" "url")
if [[ -n "$TODO_URL" ]]; then
    RESPONSE=$(patch "$TODO_URL" '{"order":95}')
    BODY=$(get_body "$RESPONSE")
    ORDER=$(json_value "$BODY" "order")
    if [[ "$ORDER" == "95" ]]; then
        pass "can PATCH a todo to change its order"
    else
        fail "PATCH todo order" "Expected order=95, got '$ORDER'"
    fi
else
    fail "PATCH todo order" "Could not get URL from created todo"
fi

# Clean slate
delete "$API_ROOT" > /dev/null

# Test 16: Remembers order changes
RESPONSE=$(post "$API_ROOT" '{"title":"blah","order":10}')
BODY=$(get_body "$RESPONSE")
TODO_URL=$(json_value "$BODY" "url")
if [[ -n "$TODO_URL" ]]; then
    RESPONSE=$(patch "$TODO_URL" '{"order":95}')
    # Re-fetch to verify persistence
    RESPONSE=$(get "$TODO_URL")
    BODY=$(get_body "$RESPONSE")
    ORDER=$(json_value "$BODY" "order")
    if [[ "$ORDER" == "95" ]]; then
        pass "remembers changes to a todo's order"
    else
        fail "remembers order changes" "Expected order=95, got '$ORDER'"
    fi
else
    fail "remembers order changes" "Could not get URL from created todo"
fi

# Summary
echo ""
echo "======================================"
echo "Test Results"
echo "======================================"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo "Total:  $((PASSED + FAILED))"
echo "======================================"

if [[ $FAILED -eq 0 ]]; then
    exit 0
else
    exit 1
fi
