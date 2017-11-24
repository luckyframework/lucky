require "../spec_helper"

private class TestPage
  include Lucky::DateHelpers
end

describe Lucky::DateHelpers do
  describe "distance_of_time_in_words" do
    it "reports the approximate distance in time between two Time" do
      from_time = Time.now
      view.distance_of_time_in_words(from_time, from_time + 1.seconds).should eq "a second"
      view.distance_of_time_in_words(from_time, from_time + 10.seconds).should eq "10 seconds"
      view.distance_of_time_in_words(from_time, from_time + 1.minutes).should eq "a minute"
      view.distance_of_time_in_words(from_time, from_time + 2.minutes).should eq "2 minutes"
      view.distance_of_time_in_words(from_time, from_time + 35.minutes).should eq "35 minutes"
      view.distance_of_time_in_words(from_time, from_time + 45.minutes).should eq "about an hour"
      view.distance_of_time_in_words(from_time, from_time + 50.minutes).should eq "about an hour"
      view.distance_of_time_in_words(from_time, from_time + 1.hours).should eq "an hour"
      view.distance_of_time_in_words(from_time, from_time + 2.hours).should eq "2 hours"
      view.distance_of_time_in_words(from_time, from_time + 1.days).should eq "a day"
      view.distance_of_time_in_words(from_time, from_time + 1.month).should eq "about a month"
      view.distance_of_time_in_words(from_time, from_time + 10.month).should eq "10 months"
      view.distance_of_time_in_words(from_time, from_time + 12.month).should eq "about a year"
      view.distance_of_time_in_words(from_time, from_time + 2.year).should eq "over 2 years"
      view.distance_of_time_in_words(from_time, from_time + 10.year).should eq "almost 10 years"
    end
  end
end

private def view
  TestPage.new
end
