# Expectations for writing specs for HTTP requests and responses
module Lucky::RequestExpectations
  # Test that the HTTP response has the expected status and JSON body
  #
  # ```
  # user = UserFactory.create
  #
  # response = AppClient.new.exec(Users::Show.with(user.id))
  #
  # response.should send_json(200, name: user.name, age: user.age)
  # ```
  def send_json(status, **expected)
    SendJsonExpectation.new(status, expected.to_json)
  end

  # :nodoc:
  struct SendJsonExpectation
    private getter expected_status : Int32
    private getter expected_json : JSON::Any

    def initialize(@expected_status, expected_json : String)
      @expected_json = JSON.parse(expected_json)
    end

    def match(actual_response : HTTP::Client::Response) : Bool
      actual_json = JSON.parse(actual_response.body)

      actual_response.status_code == expected_status &&
        actual_response_includes_expected_json?(actual_json)
    rescue JSON::ParseException
      false
    end

    private def actual_response_includes_expected_json?(actual_json) : Bool
      expected_json.as_h.all? do |expected_key, expected_value|
        actual_json.as_h.has_key?(expected_key) &&
          actual_json.as_h[expected_key] == expected_value
      end
    end

    def failure_message(actual_response : HTTP::Client::Response) : String
      if actual_response.status_code != expected_status
        "Expected status of #{expected_status}. Instead got #{actual_response.status_code}."
      else
        incorrect_response_body_message(actual_response)
      end
    rescue JSON::ParseException
      "Response body is not valid JSON."
    end

    private def incorrect_response_body_message(actual_response : HTTP::Client::Response) : String
      actual_json = JSON.parse(actual_response.body).as_h

      expected_json.as_h.each { |expected_key, expected_value|
        if !actual_json.has_key?(expected_key)
          break <<-TEXT
          Expected response to have JSON key #{expected_key.dump}, but it was not present.

          Response keys: #{actual_json.keys.map(&.dump).join(", ")}
          TEXT
        elsif actual_json[expected_key]? != expected_value
          break <<-TEXT
          JSON response was incorrect.

          Expected #{expected_key.dump} to be:

            #{expected_value.inspect}

          Instead got:

            #{actual_json[expected_key].inspect}
          TEXT
        end
      }.to_s
    end

    def negative_failure_message(actual_value) : String
      "Didn't expect JSON response to match, but it was the same."
    end
  end
end
