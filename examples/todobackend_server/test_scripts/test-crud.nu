#!/usr/bin/env nu

use std assert

# Function to test CRUD operations
def test-crud [
  alice: record,
  charlie: record,
  bob: record,
  base_url: string
] {
  $alice
  | to json
  | http post $"($base_url)/new"
  | do { assert equal $in.status 201; $in }
  | http get $"($base_url)/alice"
  | assert equal $in $alice
  | do { $charlie }
  | to json
  | http put $"($base_url)/alice"
  | do { assert equal $in.status 200; $in }
  | http get $"($base_url)/alice"
  | assert equal $in $charlie
  | do { $bob }
  | to json
  | http post $base_url
  | do { assert equal $in.status 200; $in }
  | http delete $"($base_url)/alice"
  | do { assert equal $in.status 200; $in }
  | http delete $"($base_url)/bob"
  | assert equal $in.status 200
}

# JSON document with person data keyed by paths
let people = {
  "/alice": {
    name: "alice",
    age: 11
  },
  "/bob": {
    name: "bob",
    age: 25
  },
  "/charlie": {
    name: "charlie",
    age: 30
  },
  "/danielle": {
    name: "danielle",
    age: 28
  }
}

# Test that tries a plain /people end point
def "test people" [] {
  test-crud ($people | get "/alice") ($people | get "/charlie") ($people | get "/bob") "http://localhost:8080/people"
}

# # Test that tries a plain /customer end point
# def "test customer" [] {
# test-crud ($people | get "/danielle") ($people | get "/charlie") ($people | get "/bob") "http://localhost:8080/customer"
# }



# # Test that calls a nested api/people
# def "test nested_api" [] {
# test-crud ($people | get "/alice") ($people | get "/charlie") ($people | get "/bob") "http://localhost:8080/api/people"
# }



# Test runner - discovers and runs all tests
def main [] {
  let test_commands = (
    scope commands
    | where ($it.type == "custom")
      and ($it.name | str starts-with "test ")
      and not ($it.description | str starts-with "ignore")
    | get name
    | each { |test| [($"print 'Running test: ($test)'"), $test] }
    | flatten
    | str join "; "
  )

  nu --commands $"source ($env.CURRENT_FILE); ($test_commands)"
}
