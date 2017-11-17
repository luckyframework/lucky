require "../spec_helper"

private class TestPage
  include LuckyWeb::PageHelpers
end

describe LuckyWeb::PageHelpers do
  describe "time_ago_in_words" do
    it "reports the approximate distance in time between two Time" do
      from_time = Time.now
      view.time_ago_in_words(from_time, from_time + 1.seconds).should eq "less than a minute"
      view.time_ago_in_words(from_time, from_time + 10.seconds).should eq "less than a minute"
      view.time_ago_in_words(from_time, from_time + 1.minutes).should eq "1 minute"
      view.time_ago_in_words(from_time, from_time + 2.minutes).should eq "2 minutes"
      view.time_ago_in_words(from_time, from_time + 35.minutes).should eq "35 minutes"
      view.time_ago_in_words(from_time, from_time + 45.minutes).should eq "about 1 hour"
      view.time_ago_in_words(from_time, from_time + 50.minutes).should eq "about 1 hour"
    end
  end
end

private def view
  TestPage.new
end
