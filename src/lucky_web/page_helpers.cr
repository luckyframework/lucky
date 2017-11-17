module LuckyWeb::PageHelpers
  def time_ago_in_words(from : Time, to : Time)
    distance_in_minutes = (to - from).minutes
    distance_in_seconds = (to - from).seconds

    case distance_in_minutes
    when 0..1    then distance_in_minutes == 0 ? "less than a minute" : "#{distance_in_minutes} minute"
    when 2...45  then "#{distance_in_minutes} minutes"
    when 45...90 then "about #{(distance_in_minutes.to_f / 60.0).round.to_i} hour"
    end
  end
end
