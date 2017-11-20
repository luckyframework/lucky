require "../../spec_helper"

class TextHelpers::Index < Lucky::Action
  action { render_text "foo" }
end

class TextHelpers::Create < Lucky::Action
  action { render_text "foo" }
end

private class TestPage
  include Lucky::HTMLPage

  def render
  end

  def test_truncate
    truncate "Hello World", length: 8 do
      link "Continue", "#"
    end
  end

  def test_highlight
    highlight "This is a beautiful morning, but also a beautiful day", "beautiful" do |word|
      "<a href=\"##{word}\">#{word}</a>"
    end
  end
end

describe Lucky::TextHelpers do
  Spec.before_each do
    view.reset_cycles
  end

  it "should truncate" do
    view.truncate("Hello World!", length: 12).should eq "Hello World!"
    view.truncate("Hello World!!", length: 12).should eq "Hello Wor..."
  end

  it "should truncate should use default length of 30" do
    str = "This is a string that will go longer then the default truncate length of 30"
    view.truncate(str).should eq str[0...27] + "..."
  end

  it "should truncate with options hash" do
    view.truncate("This is a string that will go longer then the default truncate length of 30", omission: "[...]").should eq "This is a string that wil[...]"
    view.truncate("Hello World!", length: 10).should eq "Hello W..."
    view.truncate("Hello World!", omission: "[...]", length: 10).should eq "Hello[...]"
    view.truncate("Hello Big World!", omission: "[...]", length: 13, separator: " ").should eq "Hello[...]"
    view.truncate("Hello Big World!", omission: "[...]", length: 14, separator: " ").should eq "Hello Big[...]"
    view.truncate("Hello Big World!", omission: "[...]", length: 15, separator: " ").should eq "Hello Big[...]"
  end

  it "should truncate with link options" do
    view.truncate("Here is a long test and I need a continue to read link", length: 27) { view.link("Continue", "#") }.should eq "Here is a long test and ...<a href=\"#\">Continue</a>"
    view.test_truncate.should eq "Hello...<a href=\"#\">Continue</a>"
  end

  it "should highlight" do
    view.highlight("This is a beautiful morning", "beautiful").should eq "This is a <mark>beautiful</mark> morning"
    view.highlight("This is a beautiful morning, but also a beautiful day", "beautiful").should eq "This is a <mark>beautiful</mark> morning, but also a <mark>beautiful</mark> day"
    view.highlight("This is a beautiful morning, but also a beautiful day", "beautiful", highlighter: "<b>\\1</b>").should eq "This is a <b>beautiful</b> morning, but also a <b>beautiful</b> day"
    view.highlight("This text is not changed because we supplied an empty phrase", nil).should eq "This text is not changed because we supplied an empty phrase"
  end

  it "should highlight pending" do
    view.highlight("   ", "blank text is returned verbatim").should eq "   "
  end

  it "should highlight should return blank string for nil" do
    view.highlight(nil, "blank string is returned for nil").should eq ""
  end

  it "should highlight with regexp" do
    view.highlight("This is a beautiful! morning", "beautiful!").should eq "This is a <mark>beautiful!</mark> morning"
    view.highlight("This is a beautiful! morning", "beautiful! morning").should eq "This is a <mark>beautiful! morning</mark>"
    view.highlight("This is a beautiful? morning", "beautiful? morning").should eq "This is a <mark>beautiful? morning</mark>"
  end

  it "should highlight accepts regexp" do
    view.highlight("This day was challenging for judge Allen and his colleagues.", /\ballen\b/i).should eq "This day was challenging for judge <mark>Allen</mark> and his colleagues."
  end

  it "should highlight with multiple phrases in one pass" do
    view.highlight("wow em", %w(wow em), highlighter: "<em>\\1</em>").should eq %(<em>wow</em> <em>em</em>)
  end

  it "should highlight with html" do
    view.highlight("<p>This is a beautiful morning, but also a beautiful day</p>", "beautiful").should eq "<p>This is a <mark>beautiful</mark> morning, but also a <mark>beautiful</mark> day</p>"
    view.highlight("<p>This is a <em>beautiful</em> morning, but also a beautiful day</p>", "beautiful").should eq "<p>This is a <em><mark>beautiful</mark></em> morning, but also a <mark>beautiful</mark> day</p>"
    view.highlight("<p>This is a <em class=\"error\">beautiful</em> morning, but also a beautiful <span class=\"last\">day</span></p>", "beautiful").should eq "<p>This is a <em class=\"error\"><mark>beautiful</mark></em> morning, but also a <mark>beautiful</mark> <span class=\"last\">day</span></p>"
    view.highlight("<p class=\"beautiful\">This is a beautiful morning, but also a beautiful day</p>", "beautiful").should eq "<p class=\"beautiful\">This is a <mark>beautiful</mark> morning, but also a <mark>beautiful</mark> day</p>"
    view.highlight("<p>This is a beautiful <a href=\"http://example.com/beautiful\#top?what=beautiful%20morning&when=now+then\">morning</a>, but also a beautiful day</p>", "beautiful").should eq "<p>This is a <mark>beautiful</mark> <a href=\"http://example.com/beautiful\#top?what=beautiful%20morning&when=now+then\">morning</a>, but also a <mark>beautiful</mark> day</p>"
    view.highlight("<div>abc div</div>", "div", highlighter: "<b>\\1</b>").should eq "<div>abc <b>div</b></div>"
  end

  it "should highlight with block" do
    view.highlight("one two three", ["one", "two", "three"]) { |word| "<b>#{word}</b>" }.should eq "<b>one</b> <b>two</b> <b>three</b>"
    view.test_highlight.should eq "This is a <a href=\"#beautiful\">beautiful</a> morning, but also a <a href=\"#beautiful\">beautiful</a> day"
  end

  it "should excerpt" do
    view.excerpt("This is a beautiful morning", "beautiful", radius: 5).should eq "...is a beautiful morn..."
    view.excerpt("This is a beautiful morning", "this", radius: 5).should eq "This is a..."
    view.excerpt("This is a beautiful morning", "morning", radius: 5).should eq "...iful morning"
    view.excerpt("This is a beautiful morning", "day").should be_nil
  end

  it "should excerpt with regex" do
    view.excerpt("This is a beautiful! morning", "beautiful", radius: 5).should eq "...is a beautiful! mor..."
    view.excerpt("This is a beautiful? morning", "beautiful", radius: 5).should eq "...is a beautiful? mor..."
    view.excerpt("This is a beautiful? morning", /\bbeau\w*\b/i, radius: 5).should eq "...is a beautiful? mor..."
    view.excerpt("This is a beautiful? morning", /\b(beau\w*)\b/i, radius: 5).should eq "...is a beautiful? mor..."
    view.excerpt("This day was challenging for judge Allen and his colleagues.", /\ballen\b/i, radius: 5).should eq "...udge Allen and..."
    view.excerpt("This day was challenging for judge Allen and his colleagues.", /\ballen\b/i, radius: 1, separator: " ").should eq "...judge Allen and..."
    view.excerpt("This day was challenging for judge Allen and his colleagues.", /\b(\w*allen\w*)\b/i, radius: 5).should eq "...was challenging for..."
  end

  it "should excerpt in borderline cases" do
    view.excerpt("", "", radius: 0).should eq ""
    view.excerpt("a", "a", radius: 0).should eq "a"
    view.excerpt("abc", "b", radius: 0).should eq "...b..."
    view.excerpt("abc", "b", radius: 1).should eq "abc"
    view.excerpt("abcd", "b", radius: 1).should eq "abc..."
    view.excerpt("zabc", "b", radius: 1).should eq "...abc"
    view.excerpt("zabcd", "b", radius: 1).should eq "...abc..."
    view.excerpt("zabcd", "b", radius: 2).should eq "zabcd"

    # excerpt strips the resulting string before ap-/prepending excerpt_string.
    # whether this behavior is meaningful when excerpt_string is not to be
    # appended is questionable.
    view.excerpt("  zabcd  ", "b", radius: 4).should eq "zabcd"
    view.excerpt("z  abc  d", "b", radius: 1).should eq "...abc..."
  end

  it "should excerpt with omission" do
    view.excerpt("This is a beautiful morning", "beautiful", omission: "[...]", radius: 5).should eq "[...]is a beautiful morn[...]"
    view.excerpt("This is the ultimate supercalifragilisticexpialidoceous very looooooooooooooooooong looooooooooooong beautiful morning with amazing sunshine and awesome temperatures. So what are you gonna do about it?", "very", omission: "[...]").should eq "This is the ultimate supercalifragilisticexpialidoceous very looooooooooooooooooong looooooooooooong beautiful morning with amazing sunshine and awesome tempera[...]"
  end

  it "should excerpt with separator" do
    view.excerpt("This is a very beautiful morning", "very", separator: " ", radius: 1).should eq "...a very beautiful..."
    view.excerpt("This is a very beautiful morning", "this", separator: " ", radius: 1).should eq "This is..."
    view.excerpt("This is a very beautiful morning", "morning", separator: " ", radius: 1).should eq "...beautiful morning"
    view.excerpt("my very\nvery\nvery long\nstring", "long", separator: "\n", radius: 0).should eq "...very long..."
    view.excerpt("my very\nvery\nvery long\nstring", "long", separator: "\n", radius: 1).should eq "...very\nvery long\nstring"
    view.excerpt("This is a beautiful morning", "a", separator: nil).should eq view.excerpt("This is a beautiful morning", "a")
  end

  it "should word wrap" do
    view.word_wrap("my very very very long string", line_width: 15).should eq "my very very\nvery long\nstring"
  end

  it "test_word_wrap_with_extra_newlines" do
    view.word_wrap("my very very very long string\n\nwith another line", line_width: 15).should eq "my very very\nvery long\nstring\n\nwith another\nline"
  end

  it "test_word_wrap_with_custom_break_sequence" do
    view.word_wrap("1234567890 " * 3, line_width: 2, break_sequence: "\r\n").should eq "1234567890\r\n1234567890\r\n1234567890"
  end

  it "pluralizes words" do
    view.pluralize(1, "count").should eq "1 count"
    view.pluralize(2, "count").should eq "2 counts"
    view.pluralize("1", "count").should eq "1 count"
    view.pluralize("2", "count").should eq "2 counts"
    view.pluralize("1,066", "count").should eq "1,066 counts"
    view.pluralize("1.25", "count").should eq "1.25 counts"
    view.pluralize("1.0", "count").should eq "1.0 count"
    view.pluralize("1.00", "count").should eq "1.00 count"
    view.pluralize(2, "count", "counters").should eq "2 counters"
    view.pluralize(nil, "count", "counters").should eq "0 counters"
    view.pluralize(2, "count", plural: "counters").should eq "2 counters"
    view.pluralize(nil, "count", plural: "counters").should eq "0 counters"
    view.pluralize(2, "person").should eq "2 people"
    view.pluralize(10, "buffalo").should eq "10 buffaloes"
    view.pluralize(1, "berry").should eq "1 berry"
    view.pluralize(12, "berry").should eq "12 berries"
  end

  describe Lucky::TextHelpers::Cycle do
    it "should cycle" do
      value = Lucky::TextHelpers::Cycle.new("one", 2, "3")
      value.to_s.should eq "one"
      value.to_s.should eq "2"
      value.to_s.should eq "3"
      value.to_s.should eq "one"
      value.reset
      value.to_s.should eq "one"
      value.to_s.should eq "2"
      value.to_s.should eq "3"
    end
  end

  it "should cycle" do
    view.cycle("one", 2, "3").should eq "one"
    view.cycle("one", 2, "3").should eq "2"
    view.cycle("one", 2, "3").should eq "3"
    view.cycle("one", 2, "3").should eq "one"
    view.cycle("one", 2, "3").should eq "2"
    view.cycle("one", 2, "3").should eq "3"
  end

  it "should cycle with array" do
    array = [1, 2, 3]
    view.cycle(array).should eq "1"
    view.cycle(array).should eq "2"
    view.cycle(array).should eq "3"
  end

  it "should cycle resets with new values" do
    view.cycle("even", "odd").should eq "even"
    view.cycle("even", "odd").should eq "odd"
    view.cycle("even", "odd").should eq "even"
    view.cycle(1, 2, 3).should eq "1"
    view.cycle(1, 2, 3).should eq "2"
    view.cycle(1, 2, 3).should eq "3"
    view.cycle(1, 2, 3).should eq "1"
  end

  it "should have named cycles" do
    view.cycle(1, 2, 3, name: "numbers").should eq "1"
    view.cycle("red", "blue", name: "colors").should eq "red"
    view.cycle(1, 2, 3, name: "numbers").should eq "2"
    view.cycle("red", "blue", name: "colors").should eq "blue"
    view.cycle(1, 2, 3, name: "numbers").should eq "3"
    view.cycle("red", "blue", name: "colors").should eq "red"
  end

  it "should have current_cycle with default name" do
    view.cycle("even", "odd")
    view.current_cycle.should eq "even"
    view.cycle("even", "odd")
    view.current_cycle.should eq "odd"
    view.cycle("even", "odd")
    view.current_cycle.should eq "even"
  end

  it "should get current_cycle with named cycles" do
    view.cycle("red", "blue", name: "colors")
    view.current_cycle("colors").should eq "red"
    view.cycle("red", "blue", name: "colors")
    view.current_cycle("colors").should eq "blue"
    view.cycle("red", "blue", name: "colors")
    view.current_cycle("colors").should eq "red"
  end

  it "should get current_cycle with no exceptions" do
    view.current_cycle.should be_nil
    view.current_cycle("colors").should be_nil
  end

  it "should get current cycle with more than two names" do
    view.cycle(1, 2, 3)
    view.current_cycle.should eq "1"
    view.cycle(1, 2, 3)
    view.current_cycle.should eq "2"
    view.cycle(1, 2, 3)
    view.current_cycle.should eq "3"
    view.cycle(1, 2, 3)
    view.current_cycle.should eq "1"
  end

  it "test_default_named_cycle" do
    view.cycle(1, 2, 3).should eq "1"
    view.cycle(1, 2, 3, name: "default").should eq "2"
    view.cycle(1, 2, 3).should eq "3"
  end

  it "should reset cycle" do
    view.cycle(1, 2, 3).should eq "1"
    view.cycle(1, 2, 3).should eq "2"
    view.reset_cycle
    view.cycle(1, 2, 3).should eq "1"
  end

  it "should reset unknown cycle" do
    view.reset_cycle("colors")
  end

  it "should reset named cycle" do
    view.cycle(1, 2, 3, name: "numbers").should eq "1"
    view.cycle("red", "blue", name: "colors").should eq "red"
    view.reset_cycle("numbers")
    view.cycle(1, 2, 3, name: "numbers").should eq "1"
    view.cycle("red", "blue", name: "colors").should eq "blue"
    view.cycle(1, 2, 3, name: "numbers").should eq "2"
    view.cycle("red", "blue", name: "colors").should eq "red"
  end
end

private def view
  TestPage.new
end
