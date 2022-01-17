module Lucky::TimeHelpers
  # Returns a `String` with approximate distance in time between `from` and `to`.
  #
  # ```
  # distance_of_time_in_words(Time.utc(2019, 8, 14, 10, 0, 0), Time.utc(2019, 8, 14, 10, 0, 5))
  # # => "5 seconds"
  # distance_of_time_in_words(Time.utc(2019, 8, 14, 10, 0), Time.utc(2019, 8, 14, 10, 25))
  # # => "25 minutes"
  # distance_of_time_in_words(Time.utc(2019, 8, 14, 10), Time.utc(2019, 8, 14, 11))
  # # => "an hour"
  # distance_of_time_in_words(Time.utc(2019, 8, 14), Time.utc(2019, 8, 16))
  # # => "2 days"
  # distance_of_time_in_words(Time.utc(2019, 8, 14), Time.utc(2019, 10, 4))
  # # => "about a month"
  # distance_of_time_in_words(Time.utc(2019, 8, 14), Time.utc(2061, 10, 4))
  # # => "almost 42 years"
  # ```
  def distance_of_time_in_words(from : Time, to : Time) : String
    minutes = (to - from).minutes
    seconds = (to - from).seconds
    hours = (to - from).hours
    days = (to - from).days

    return distance_in_days(days) if days != 0
    return distance_in_hours(hours, minutes) if hours != 0
    return distance_in_minutes(minutes) if minutes != 0

    distance_in_seconds(seconds)
  end

  # Returns a `String` with approximate distance in time between `from` and current moment.

  def time_ago_in_words(from : Time) : String
    distance_of_time_in_words(from, Time.utc)
  end

  # Returns a `String` with approximate distance in time between current moment and future date.
  #
  # ```
  # time_from_now_in_words(Time.utc(2022, 8, 30)) # => "about a year"
  # # gives the same result as:
  # distance_of_time_in_words(Time.utc, Time.utc(2022, 8, 30)) # => "about a year"
  # ```
  #
  # See more examples in `#distance_of_time_in_words`.
  def time_from_now_in_words(to : Time) : String
    distance_of_time_in_words(Time.utc, to)
  end

  private def distance_in_days(distance : Int) : String
    case distance
    when 1...27   then distance == 1 ? "a day" : "#{distance} days"
    when 27...60  then "about a month"
    when 60...365 then "#{(distance / 30).round.to_i} months"
    when 365...730
      "about a year"
    when 730...1460
      "over #{(distance / 365).round.to_i} years"
    else
      "almost #{(distance / 365).round.to_i} years"
    end
  end

  private def distance_in_hours(hours : Int32, minutes : Int32) : String
    if minutes >= 45
      "almost #{hours + 1} hours"
    elsif hours == 1
      "an hour"
    else
      "#{hours} hours"
    end
  end

  private def distance_in_minutes(distance : Int32) : String
    case distance
    when 1      then "a minute"
    when 2...45 then "#{distance} minutes"
    else
      "about an hour"
    end
  end

  private def distance_in_seconds(distance : Int32) : String
    distance == 1 ? "a second" : "#{distance} seconds"
  end
end
