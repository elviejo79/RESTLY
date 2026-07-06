note
	description: "Tests for WSF_JSON_RESPONSE."

class
	TEST_WSF_JSON_RESPONSE

inherit
	EQA_TEST_SET

feature -- Tests: Default bodies are valid JSON

	test_error_body_is_valid_json
		local
			l_resp: WSF_JSON_RESPONSE
			l_key_error, l_key_status: JSON_STRING
		do
			l_resp := {WSF_JSON_RESPONSE}.not_found
			check attached l_resp.json_body as l_obj then
				l_key_error := "error"
				l_key_status := "status"
				assert ("has error key", l_obj.has_key (l_key_error))
				assert ("has status key", l_obj.has_key (l_key_status))
				check attached l_obj.string_item (l_key_error) as l_err then
					assert ("error value", l_err.item.has_substring ("Not Found"))
				end
			end
		end

	test_success_body_uses_message_key
		local
			l_resp: WSF_JSON_RESPONSE
			l_key_message: JSON_STRING
		do
			l_resp := {WSF_JSON_RESPONSE}.ok
			check attached l_resp.json_body as l_obj then
				l_key_message := "message"
				assert ("has message key", l_obj.has_key (l_key_message))
			end
		end

feature -- Tests: Content-type on all creation paths

	test_make_sets_json_content_type
		local
			l_resp: WSF_JSON_RESPONSE
		do
			create l_resp.make
			assert ("has content-type", l_resp.header.has_content_type)
			assert ("json ct", l_resp.header.string.has_substring ("application/json"))
		end

	test_make_with_body_sets_json_content_type
		local
			l_resp: WSF_JSON_RESPONSE
		do
			create l_resp.make_with_body ("{}")
			assert ("has content-type", l_resp.header.has_content_type)
			assert ("json ct", l_resp.header.string.has_substring ("application/json"))
		end

	test_make_with_status_sets_json_content_type
		local
			l_resp: WSF_JSON_RESPONSE
		do
			create l_resp.make_with_status (200)
			assert ("has content-type", l_resp.header.has_content_type)
			assert ("json ct", l_resp.header.string.has_substring ("application/json"))
		end

feature -- Tests: Escaping regression

	test_with_detail_escapes_special_chars
		local
			l_resp: WSF_JSON_RESPONSE
			l_key_detail: JSON_STRING
		do
			l_resp := {WSF_JSON_RESPONSE}.bad_request.with_detail ("quotes%"here%H newline%Nend")
			check attached l_resp.json_body as l_obj then
				l_key_detail := "detail"
				assert ("has detail", l_obj.has_key (l_key_detail))
				check attached l_obj.string_item (l_key_detail) as l_det then
					assert ("round-trips quotes", l_det.item.has_substring ("quotes"))
				end
			end
		end

feature -- Tests: 204 No Content has no body

	test_no_content_has_no_body
		local
			l_resp: WSF_JSON_RESPONSE
		do
			l_resp := {WSF_JSON_RESPONSE}.no_content
			assert ("no body", l_resp.body = Void)
		end

feature -- Tests: Fluent setters

	test_with_location_sets_header
		local
			l_resp: WSF_JSON_RESPONSE
		do
			l_resp := {WSF_JSON_RESPONSE}.created.with_location ("/todos/42")
			assert ("location header", l_resp.header.string.has_substring ("Location"))
			assert ("location value", l_resp.header.string.has_substring ("/todos/42"))
		end

	test_with_location_returns_current
		local
			l_resp, l_result: WSF_JSON_RESPONSE
		do
			l_resp := {WSF_JSON_RESPONSE}.created
			l_result := l_resp.with_location ("/x")
			assert ("same object", l_result = l_resp)
		end

	test_with_json_object_sets_body
		local
			l_resp: WSF_JSON_RESPONSE
			l_obj: JSON_OBJECT
		do
			create l_obj.make_with_capacity (1)
			l_obj.put_string ("bar", "foo")
			l_resp := {WSF_JSON_RESPONSE}.ok.with_json_object (l_obj)
			check attached l_resp.body as l_body then
				assert ("has foo", l_body.has_substring ("foo"))
				assert ("has bar", l_body.has_substring ("bar"))
			end
		end

end
