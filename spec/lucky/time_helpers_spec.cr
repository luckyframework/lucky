require "../spec_helper"

private class TestPage
  include Lucky::HTMLPage
  include Lucky::TimeHelpers
end

describe Lucky::TimeHelpers do
  describe "distance_of_time_in_words" do
    it "reports the approximate distance in time between two Time" do
      from_time = Time.now
      view.distance_of_time_in_words(from_time, from_time + 1.second).to_s.should eq "a second"
      view.distance_of_time_in_words(from_time, from_time + 10.seconds).to_s.should eq "10 seconds"
      view.distance_of_time_in_words(from_time, from_time + 1.minute).to_s.should eq "a minute"
      view.distance_of_time_in_words(from_time, from_time + 2.minutes).to_s.should eq "2 minutes"
      view.distance_of_time_in_words(from_time, from_time + 35.minutes).to_s.should eq "35 minutes"
      view.distance_of_time_in_words(from_time, from_time + 45.minutes).to_s.should eq "about an hour"
      view.distance_of_time_in_words(from_time, from_time + 50.minutes).to_s.should eq "about an hour"
      view.distance_of_time_in_words(from_time, from_time + 1.hour).to_s.should eq "an hour"
      view.distance_of_time_in_words(from_time, from_time + 2.hours).to_s.should eq "2 hours"
      view.distance_of_time_in_words(from_time, from_time + 1.day).to_s.should eq "a day"
      view.distance_of_time_in_words(from_time, from_time + 10.days).to_s.should eq "10 days"
      view.distance_of_time_in_words(from_time, from_time + 1.month).to_s.should eq "about a month"
      view.distance_of_time_in_words(from_time, from_time + 10.months).to_s.should eq "10 months"
      view.distance_of_time_in_words(from_time, from_time + 12.months).to_s.should eq "about a year"
      view.distance_of_time_in_words(from_time, from_time + 2.years).to_s.should eq "over 2 years"
      view.distance_of_time_in_words(from_time, from_time + 10.years).to_s.should eq "almost 10 years"
    end
  end

  describe "time_ago_in_words" do
    it "returns the distance from now" do
      view.time_ago_in_words(Time.now - 13.months).to_s.should eq "about a year"
    end
  end
end

private def view
  TestPage.new
end
