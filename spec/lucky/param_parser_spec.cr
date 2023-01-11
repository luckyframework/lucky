require "../spec_helper"

enum TimeComponent
  Year
  Month
  Day
  Hour
  Minute
  Second
end

struct FormattedTime
  property label : String
  property value : String
  property components : Array(TimeComponent)

  def initialize(@label : String, @value : String, excluded_components : Array(TimeComponent) = [] of TimeComponent)
    @components = [
      TimeComponent::Year,
      TimeComponent::Month,
      TimeComponent::Day,
      TimeComponent::Hour,
      TimeComponent::Minute,
      TimeComponent::Second,
    ] - excluded_components
  end
end

macro numbers_tests(klass, input, output)
  describe "parse {{ klass }}" do
    it "turns string into number" do
      Lucky::ParamParser.parse({{ input }}, {{ klass }}).should eq({{ output }})
    end

    it "returns nil if param not number" do
      Lucky::ParamParser.parse("abc", {{ klass }}).should be_nil
    end

    it "returns nil if param blank" do
      Lucky::ParamParser.parse("", {{ klass }}).should be_nil
    end
  end
end

describe Lucky::ParamParser do
  numbers_tests(Int16, "1", 1_i16)
  numbers_tests(Int32, "12", 12)
  numbers_tests(Int64, "144", 144_i64)
  numbers_tests(Float64, "1.23", 1.23_f64)

  describe "parse String" do
    it "does not change the value" do
      Lucky::ParamParser.parse("foo", String).should eq("foo")
    end
  end

  describe "parse Bool" do
    it "parses forms of true" do
      Lucky::ParamParser.parse("true", Bool).should be_true
      Lucky::ParamParser.parse("1", Bool).should be_true
    end

    it "parses forms of false" do
      Lucky::ParamParser.parse("false", Bool).should be_false
      Lucky::ParamParser.parse("0", Bool).should be_false
    end

    it "returns nil for other values" do
      Lucky::ParamParser.parse("asdf", Bool).should be_nil
    end
  end

  describe "parse UUID" do
    it "parses uuid string" do
      uuid = "0881a13e-e283-45a0-9dba-6d05463eec45"

      Lucky::ParamParser.parse(uuid, UUID).should eq(UUID.new(uuid))
    end

    it "returns nil if not uuid" do
      Lucky::ParamParser.parse("INVALID", UUID).should be_nil
    end
  end

  describe "parse Time" do
    it "parses various formats successfully" do
      time = Time.utc
      [
        FormattedTime.new("ISO 8601", time.to_s("%FT%X%z")),
        FormattedTime.new("RFC 2822", time.to_rfc2822),
        FormattedTime.new("RFC 3339", time.to_rfc3339),
        FormattedTime.new("DateTime HTML Input", time.to_s("%Y-%m-%dT%H:%M:%S")),
        FormattedTime.new("DateTime HTML Input (no seconds)", time.to_s("%Y-%m-%dT%H:%M"), excluded_components: [TimeComponent::Second]),
        FormattedTime.new("HTTP Date", time.to_s("%a, %d %b %Y %H:%M:%S GMT")),
      ].each do |formatted_time|
        result = Lucky::ParamParser.parse(formatted_time.value, Time)

        result.should_not be_nil
        result = result.as(Time)
        result.year.should eq(time.year) if formatted_time.components.includes? TimeComponent::Year
        result.month.should eq(time.month) if formatted_time.components.includes? TimeComponent::Month
        result.day.should eq(time.day) if formatted_time.components.includes? TimeComponent::Day
        result.hour.should eq(time.hour) if formatted_time.components.includes? TimeComponent::Hour
        result.minute.should eq(time.minute) if formatted_time.components.includes? TimeComponent::Minute
        result.second.should eq(time.second) if formatted_time.components.includes? TimeComponent::Second
      end
    end

    it "returns nil if unable to parse" do
      Lucky::ParamParser.parse("INVALID", Time).should be_nil
    end
  end

  describe "parse Array(T)" do
    it "handles strings" do
      Lucky::ParamParser.parse(["a", "b"], Array(String)).should eq(["a", "b"])
    end

    it "handles numbers" do
      Lucky::ParamParser.parse(["1", "2"], Array(Int32)).should eq([1, 2])
    end

    it "handles bools" do
      Lucky::ParamParser.parse(["1", "0", "true"], Array(Bool)).should eq([true, false, true])
    end
  end
end
