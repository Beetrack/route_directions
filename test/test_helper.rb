require 'minitest/autorun'
require_relative './fixtures/response'

def stub_request_with(json_responses, &block)
  http = MiniTest::Mock.new
  json_responses.each do |json_response|
    response = mock_http_response(json_response)

    http.expect(:get, response) { |_path, _headers| true }
    http.expect(:use_ssl=, nil) { |_ssl| true }
    http.expect(:read_timeout=, nil) { |_timeout| true }
    http.expect(:open_timeout=, nil) { |_timeout| true }
  end

  Net::HTTP.stub :new, http, &block
end

def mock_http_response(json_response)
  response = MiniTest::Mock.new
  response.expect :is_a?, true, [Net::HTTPSuccess]
  response.expect(:[], 'Ok') { |_status| true }
  response.expect :message, 'Ok'
  response.expect :body, json_response
  response
end
