#!/usr/bin/env bash
set -euo pipefail

BASE="http://localhost:8080"
PASS=0
FAIL=0

check() {
	local label="$1" expected="$2" actual="$3"
	if [ "$actual" = "$expected" ]; then
		echo "  PASS: $label"
		PASS=$((PASS + 1))
	else
		echo "  FAIL: $label (expected=$expected actual=$actual)"
		FAIL=$((FAIL + 1))
	fi
}

check_contains() {
	local label="$1" needle="$2" haystack="$3"
	if echo "$haystack" | grep -q "$needle"; then
		echo "  PASS: $label"
		PASS=$((PASS + 1))
	else
		echo "  FAIL: $label (missing '$needle')"
		FAIL=$((FAIL + 1))
	fi
}

echo "=== Smoke tests for todobackend ==="
echo ""

# 1. POST /todos — create first item
echo "1. POST /todos (create)"
RESP=$(curl -s -w "\n%{http_code}" -X POST "$BASE/todos" \
	-H "Content-Type: application/json" -d '{"title":"buy milk","order":1}')
CODE=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
check "status 201" "201" "$CODE"
check_contains "body has url" '"url"' "$BODY"
check_contains "body has title" '"buy milk"' "$BODY"

# 2. POST /todos — create second item
echo "2. POST /todos (second item)"
RESP=$(curl -s -w "\n%{http_code}" -X POST "$BASE/todos" \
	-H "Content-Type: application/json" -d '{"title":"walk dog","order":2}')
CODE=$(echo "$RESP" | tail -1)
check "status 201" "201" "$CODE"

# 3. GET /todos — list all
echo "3. GET /todos (list)"
RESP=$(curl -s -w "\n%{http_code}" "$BASE/todos")
CODE=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
check "status 200" "200" "$CODE"
check_contains "has buy milk" "buy milk" "$BODY"
check_contains "has walk dog" "walk dog" "$BODY"

# 4. GET /todos/1 — single item
echo "4. GET /todos/1 (single)"
RESP=$(curl -s -w "\n%{http_code}" "$BASE/todos/1")
CODE=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
check "status 200" "200" "$CODE"
check_contains "has buy milk" "buy milk" "$BODY"
check_contains "has url" '"url"' "$BODY"

# 5. GET /todos/999 — unknown id
echo "5. GET /todos/999 (unknown id)"
CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/todos/999")
check "status 404 or 412" "true" "$([ "$CODE" = "404" ] || [ "$CODE" = "412" ] && echo true || echo false)"

# 6. PATCH /todos/1 — partial update
echo "6. PATCH /todos/1 (partial update)"
RESP=$(curl -s -w "\n%{http_code}" -X PATCH "$BASE/todos/1" \
	-H "Content-Type: application/json" -d '{"completed":true}')
CODE=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
check "status 200" "200" "$CODE"
check_contains "title unchanged" "buy milk" "$BODY"
check_contains "completed added" "completed" "$BODY"

# 7. DELETE /todos/2 — delete single
echo "7. DELETE /todos/2 (single)"
CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$BASE/todos/2")
check "status 204" "204" "$CODE"

# 8. DELETE /todos — wipe all
echo "8. DELETE /todos (wipe)"
CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$BASE/todos")
check "status 200" "200" "$CODE"

# 9. GET /todos — empty after wipe
echo "9. GET /todos (after wipe)"
RESP=$(curl -s -w "\n%{http_code}" "$BASE/todos")
CODE=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')
check "status 200" "200" "$CODE"
check "empty array" "[]" "$BODY"

# 10. PUT /todos/1 — 405 Method Not Allowed
echo "10. PUT /todos/1 (405)"
CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$BASE/todos/1" \
	-H "Content-Type: application/json" -d '{}')
check "status 405" "405" "$CODE"

# 11. OPTIONS /todos — CORS headers
echo "11. OPTIONS /todos (CORS)"
HEADERS=$(curl -s -D- -o /dev/null -X OPTIONS "$BASE/todos")
check_contains "Access-Control-Allow-Origin" "Access-Control-Allow-Origin" "$HEADERS"
check_contains "Access-Control-Allow-Methods" "Access-Control-Allow-Methods" "$HEADERS"

# 12. CORS headers on regular GET
echo "12. GET /todos (CORS on regular response)"
HEADERS=$(curl -s -D- -o /dev/null "$BASE/todos")
check_contains "CORS on GET" "Access-Control-Allow-Origin" "$HEADERS"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
