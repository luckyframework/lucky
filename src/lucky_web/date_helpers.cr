module LuckyWeb::DateHelpers
  def distance_of_time_in_words(from : Time, to : Time)
    minutes = (to - from).minutes
    seconds = (to - from).seconds
    hours = (to - from).hours
    days = (to - from).days

    return distance_in_days(days) if days != 0
    return distance_in_hours(hours) if hours != 0
    return distance_in_minutes(minutes) if minutes != 0
    return distance_in_seconds(seconds) if seconds != 0
  end

  def time_ago_in_words(from : Time)
    distance_of_time_in_words(from, Time.now)
  end

  private def distance_in_days(distance : Int32)
    case distance
    when 1...29 then distance ? "a day" : "#{distance} days"
    when 30...60 then "about a month"
    when 60...365 then "#{(distance / 30).round} months"
    when 365...730
      "about a year"
    when 730...1460
      "over #{(distance / 365).round} years"
    when 1460...146000
      "almost #{(distance / 365).round} years"
    end
  end

  private def distance_in_hours(distance : Int32)
    distance == 1 ? "an hour" : "#{distance} hours"
  end

  private def distance_in_minutes(distance : Int32)
    case distance
    when       1 then "a minute"
    when 2...45  then "#{distance} minutes"
    when 45...90 then "about an hour"
    end
  end

  private def distance_in_seconds(distance : Int32)
    distance == 1 ? "a second" : "#{distance} seconds"
  end
end
