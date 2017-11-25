require "./text_helpers_spec"

describe Lucky::TextHelpers do
  describe "word_word" do
    it "word wraps" do
      view.word_wrap("my very very very long string", line_width: 15).should eq "my very very\nvery long\nstring"
    end

    it "word wraps with extra newlines" do
      view.word_wrap("my very very very long string\n\nwith another line", line_width: 15).should eq "my very very\nvery long\nstring\n\nwith another\nline"
    end

    it "word wraps with custom break sequence" do
      view.word_wrap("1234567890 " * 3, line_width: 2, break_sequence: "\r\n").should eq "1234567890\r\n1234567890\r\n1234567890"
    end
  end
end
