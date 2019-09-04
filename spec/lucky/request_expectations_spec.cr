require "../spec_helper"

include Lucky::RequestExpectations

describe Lucky::RequestExpectations do
  it "fails if the status is incorrect" do
    failure_message = "Expected status of 200. Instead got 201."
    expect_raises Spec::AssertionFailed, failure_message do
      response = build_response(201)
      response.should send_json(200)
    end
  end

  it "fails if the JSON is not parseable" do
    failure_message = "Response body is not valid JSON."
    expect_raises Spec::AssertionFailed, failure_message do
      response = build_response(200, body: "this is not json")
      response.should send_json(200)
    end
  end

  it "fails if an expected key is missing" do
    failure_message = /Expected response to have JSON key "admin"/
    expect_raises Spec::AssertionFailed, failure_message do
      response = build_response(200, {foo: "bar"}.to_json)
      response.should send_json(200, admin: true)
    end
  end

  it "fails if expected value is 'nil' and actual response key is missing" do
    failure_message = /Expected response to have JSON key "name"/
    expect_raises Spec::AssertionFailed, failure_message do
      response = build_response(200, "{}")
      response.should send_json(200, name: nil)
    end
  end

  it "fails if key is present but value is incorrect" do
    failure_message = /JSON response was incorrect/
    expect_raises Spec::AssertionFailed, failure_message do
      response = build_response(200, {admin: "true"}.to_json)
      response.should send_json(200, admin: true)
    end
  end

  it "passes if the response is exactly the same" do
    response = build_response(200, {name: "Paul"}.to_json)
    response.should send_json(200, name: "Paul")
  end

  it "passes if nested values are JSON objects" do
    response = build_response(200, {name: "Paul", comment: {id: 1}}.to_json)
    response.should send_json(200, name: "Paul", comment: {id: 1})
  end

  it "passes if the response has matching keys/values and ignores extra keys/values" do
    response = build_response(200, {name: "Paul", dont_care: "about this"}.to_json)
    response.should send_json(200, name: "Paul")
  end

  it "passes if responses are different and we're expecting that" do
    response = build_response(201, {name: "Paul"}.to_json)
    response.should_not send_json(200, name: "Paul")

    failure_message = /Didn't expect JSON response to match/
    expect_raises Spec::AssertionFailed, failure_message do
      response = build_response(200, {admin: true}.to_json)
      response.should_not send_json(200, admin: true)
    end
  end
end

private def build_response(status : Int32, body : String = "{}")
  HTTP::Client::Response.new(
    status_code: status,
    body: body
  )
end
