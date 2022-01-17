require "../spec_helper"

include ContextHelper

private class TestPage
  include Lucky::HTMLPage
  include Lucky::TimeHelpers
end

describe Lucky::TimeHelpers do
  describe "distance_of_time_in_words" do
    it "reports the approximate distance in time between two Time" do
      from_time = Time.local
      view.distance_of_time_in_words(from_time, from_time + 1.second).should eq "a second"
      view.distance_of_time_in_words(from_time, from_time + 10.seconds).should eq "10 seconds"
      view.distance_of_time_in_words(from_time, from_time + 1.minute).should eq "a minute"
      view.distance_of_time_in_words(from_time, from_time + 2.minutes).should eq "2 minutes"
      view.distance_of_time_in_words(from_time, from_time + 35.minutes).should eq "35 minutes"
      view.distance_of_time_in_words(from_time, from_time + 45.minutes).should eq "about an hour"
      view.distance_of_time_in_words(from_time, from_time + 50.minutes).should eq "about an hour"
      view.distance_of_time_in_words(from_time, from_time + 1.hour).should eq "an hour"
      view.distance_of_time_in_words(from_time, from_time + 110.minutes).should eq "almost 2 hours"
      view.distance_of_time_in_words(from_time, from_time + 350.minutes).should eq "almost 6 hours"
      view.distance_of_time_in_words(from_time, from_time + 2.hours).should eq "2 hours"
      view.distance_of_time_in_words(from_time, from_time + 1.day).should eq "a day"
      view.distance_of_time_in_words(from_time, from_time + 10.days).should eq "10 days"
      view.distance_of_time_in_words(from_time, from_time + 1.month).should eq "about a month"
      view.distance_of_time_in_words(from_time, from_time + 10.months).should eq "10 months"
      view.distance_of_time_in_words(from_time, from_time + 12.months).should eq "about a year"
      view.distance_of_time_in_words(from_time, from_time + 2.years).should eq "over 2 years"
      view.distance_of_time_in_words(from_time, from_time + 10.years).should eq "almost 10 years"
    end
  end

  describe "time_ago_in_words" do
    it "returns the distance from now" do
      view.time_ago_in_words(Time.local - 13.months).should eq "about a year"
    end
  end

  describe "time_from_now_in_words" do
    it "returns the distance between now and future date" do
      view.time_from_now_in_words(Time.local + 13.months).should eq "about a year"
    end
  end
end

private def view
  TestPage.new(build_context)
end
