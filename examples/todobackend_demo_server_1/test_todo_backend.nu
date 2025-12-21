#!/usr/bin/env nu
# Simple sequential Todo-Backend API test script

let API_ROOT = if ($env | get --ignore-errors ARGS | default [] | length) > 0 {
    $env.ARGS.0
} else {
    "http://localhost:8080/todos/"
}

print $"Testing API: ($API_ROOT)"
print ""

# GET - expect empty list
print "GET /todos/ - expect empty list"
http get --headers [Content-Type application/json] $API_ROOT
sleep 5sec

# POST - create todo
print "\nPOST /todos/ - create 'walk the dog'"
http post --headers [Content-Type application/json] --content-type application/json $API_ROOT '{"title":"walk the dog"}'
sleep 5sec

# GET - expect one todo
print "\nGET /todos/ - expect one todo"
let todos = (http get --headers [Content-Type application/json] $API_ROOT)
print $todos
sleep 5sec

# DELETE all
print "\nDELETE /todos/ - delete all"
http delete --headers [Content-Type application/json] $API_ROOT
sleep 5sec

# POST - create with completed field
print "\nPOST /todos/ - create with completed=false"
let todo1 = (http post --headers [Content-Type application/json] --content-type application/json $API_ROOT '{"title":"my todo"}')
print $todo1
let todo1_url = ($todo1 | get url)
sleep 5sec

# GET individual todo
print $"\nGET ($todo1_url) - get individual todo"
http get --headers [Content-Type application/json] $todo1_url
sleep 5sec

# PATCH - change title
print $"\nPATCH ($todo1_url) - change title"
http patch --headers [Content-Type application/json] --content-type application/json $todo1_url '{"title":"new title"}'
sleep 5sec

# PATCH - mark completed
print $"\nPATCH ($todo1_url) - mark completed"
http patch --headers [Content-Type application/json] --content-type application/json $todo1_url '{"completed":true}'
sleep 5sec

# GET - verify changes
print $"\nGET ($todo1_url) - verify changes"
http get --headers [Content-Type application/json] $todo1_url
sleep 5sec

# DELETE individual todo
print $"\nDELETE ($todo1_url) - delete individual todo"
http delete --headers [Content-Type application/json] $todo1_url
sleep 5sec

# GET - verify empty
print "\nGET /todos/ - verify empty after delete"
http get --headers [Content-Type application/json] $API_ROOT
sleep 5sec

# POST - create with order
print "\nPOST /todos/ - create with order=523"
let todo2 = (http post --headers [Content-Type application/json] --content-type application/json $API_ROOT '{"title":"ordered todo","order":523}')
print $todo2
let todo2_url = ($todo2 | get url)
sleep 5sec

# PATCH - change order
print $"\nPATCH ($todo2_url) - change order to 95"
http patch --headers [Content-Type application/json] --content-type application/json $todo2_url '{"order":95}'
sleep 5sec

# GET - verify order change
print $"\nGET ($todo2_url) - verify order change"
http get --headers [Content-Type application/json] $todo2_url
sleep 5sec

print "\nDone!"
