note
	description: "Test runner application that executes AutoTest test cases from command line"
	author: "Test Runner"
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_RUNNER

inherit
	ARGUMENTS_32

create
	make

feature {NONE} -- Initialization

	make
			-- Run all test cases and report results
		do
			print ("=== RESTFUL Library Test Runner ===%N%N")

			total_tests := 0
			passed_tests := 0
			failed_tests := 0

			-- Run all test suites
			run_rest_table_tests
			run_directory_resource_tests
			run_dns_tests
			run_github_tests
			run_motivating_example_tests

			-- Print summary
			print_summary
		end

feature {NONE} -- Test execution

	run_rest_table_tests
			-- Run REST_TABLE test cases
		local
			test_set: TEST_REST_TABLE
		do
			print ("Running REST_TABLE tests...%N")
			create test_set

			-- Test assignment
			execute_test ("test_assignment", agent test_set.test_assignment)

			-- Test resource table
			execute_test ("test_resource_table", agent test_set.test_resource_table)
		end

	run_directory_resource_tests
			-- Run DIRECTORY_RESOURCE test cases
		local
			test_set: TEST_DIRECTORY_RESOURCE
		do
			print ("Running DIRECTORY_RESOURCE tests...%N")
			create test_set

			-- Add specific test method calls here when you examine the test class
			print ("  [Skipped - examine TEST_DIRECTORY_RESOURCE class for specific tests]%N")
		end

	run_dns_tests
			-- Run DNS test cases
		local
			test_set: TEST_DNS
		do
			print ("Running DNS tests...%N")
			create test_set

			-- Add specific test method calls here when you examine the test class
			print ("  [Skipped - examine TEST_DNS class for specific tests]%N")
		end

	run_github_tests
			-- Run GitHub-related test cases
		local
			test_set: TEST_GITHUB_EXPERIMENTS
		do
			print ("Running GitHub tests...%N")
			create test_set

			-- Add specific test method calls here when you examine the test class
			print ("  [Skipped - examine TEST_GITHUB_EXPERIMENTS class for specific tests]%N")
		end

	run_motivating_example_tests
			-- Run motivating example test cases
		local
			test_set: TEST_MOTIVATING_EXAMPLE
		do
			print ("Running motivating example tests...%N")
			create test_set

			-- Add specific test method calls here when you examine the test class
			print ("  [Skipped - examine TEST_MOTIVATING_EXAMPLE class for specific tests]%N")
		end

feature {NONE} -- Test execution helpers

	execute_test (test_name: STRING; test_agent: PROCEDURE)
			-- Execute a single test and report result
		do
			total_tests := total_tests + 1
			print ("  Running " + test_name + "...")

			-- Try to execute test
			if safe_execute_test (test_agent) then
				print (" PASSED%N")
				passed_tests := passed_tests + 1
			else
				print (" FAILED%N")
				failed_tests := failed_tests + 1
			end
		end

	safe_execute_test (test_agent: PROCEDURE): BOOLEAN
			-- Safely execute a test, catching any exceptions
		do
			Result := True
			test_agent.call
		rescue
			Result := False
			retry
		end

feature {NONE} -- Reporting

	print_summary
			-- Print test execution summary
		do
			print ("%N=== Test Summary ===%N")
			print ("Total tests: " + total_tests.out + "%N")
			print ("Passed: " + passed_tests.out + "%N")
			print ("Failed: " + failed_tests.out + "%N")

			if failed_tests = 0 then
				print ("Result: ALL TESTS PASSED ✓%N")
			else
				print ("Result: " + failed_tests.out + " TESTS FAILED ✗%N")
			end
		end

feature {NONE} -- Counters

	total_tests: INTEGER
	passed_tests: INTEGER
	failed_tests: INTEGER

end
