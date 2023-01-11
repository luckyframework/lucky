module Lucky::ParamParser
  TIME_FORMATS = [
    Time::Format::ISO_8601_DATE_TIME,
    Time::Format::RFC_2822,
    Time::Format::RFC_3339,
    # HTML datetime-local inputs are basically RFC 3339 without the timezone:
    # https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/datetime-local
    Time::Format.new("%Y-%m-%dT%H:%M:%S", Time::Location::UTC),
    Time::Format.new("%Y-%m-%dT%H:%M", Time::Location::UTC),
    # Dates and times go last, otherwise it will parse strings with both
    # dates *and* times incorrectly.
    Time::Format::HTTP_DATE,
    Time::Format::ISO_8601_DATE,
    Time::Format::ISO_8601_TIME,
  ]

  def self.parse(param : String, klass : String.class) : String
    param
  end

  def self.parse(param : String, klass : Int16.class) : Int16?
    param.to_i16?
  end

  def self.parse(param : String, klass : Int32.class) : Int32?
    param.to_i?
  end

  def self.parse(param : String, klass : Int64.class) : Int64?
    param.to_i64?
  end

  def self.parse(param : String, klass : Float64.class) : Float64?
    param.to_f?
  end

  def self.parse(param : String, klass : Bool.class) : Bool?
    if %w(true 1).includes? param
      true
    elsif %w(false 0).includes? param
      false
    else
      nil
    end
  end

  def self.parse(param : String, klass : UUID.class) : UUID?
    UUID.new(param)
  rescue
    nil
  end

  def self.parse(param : String, klass : Time.class) : Time?
    TIME_FORMATS.each do |format|
      begin
        parsed = format.parse(param)
        return parsed if parsed
      rescue e : Time::Format::Error
        nil
      end
    end
  end

  # Returns `Array(T)` if all params in `param` are properly cast
  def self.parse(param : Array(String), klass : Array(T).class) : Array(T)? forall T
    casts = param.compact_map { |val| parse(val, T) }

    casts.size == param.size ? casts.as(Array(T)) : nil
  end
end
