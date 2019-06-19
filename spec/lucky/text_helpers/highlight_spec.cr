require "./text_helpers_spec"

class TextHelperTestPage
  def test_highlight
    highlight "This is a beautiful morning, but also a beautiful day", "beautiful" { |word|
      # you can't use HTMLPage here since they append to 'view' rather than return in-place
      # the block highlight expects is passed to gsub which expects to get a string returned
      "<span data-highlight-word=\"#{word}\" data-color=\"yellow\" data-español=\"bello\">#{word}</span>"
    }
  end
end

describe Lucky::TextHelpers do
  describe "highlight" do
    it "highlights" do
      view.highlight("This is a beautiful morning", "beautiful").to_s.should eq "This is a <mark>beautiful</mark> morning"
      view.highlight("This is a beautiful morning, but also a beautiful day", "beautiful").to_s.should eq "This is a <mark>beautiful</mark> morning, but also a <mark>beautiful</mark> day"
      view.highlight("This is a beautiful morning, but also a beautiful day", "beautiful", highlighter: "<b>\\1</b>").to_s.should eq "This is a <b>beautiful</b> morning, but also a <b>beautiful</b> day"
      view.highlight("This text is not changed because we supplied an empty phrase", "").to_s.should eq "This text is not changed because we supplied an empty phrase"
    end

    it "does not highlight empty text" do
      view.highlight("   ", "blank text is returned verbatim").to_s.should eq "   "
    end

    it "highlights with regexp" do
      view.highlight("This is a beautiful! morning", "beautiful!").to_s.should eq "This is a <mark>beautiful!</mark> morning"
      view.highlight("This is a beautiful! morning", "beautiful! morning").to_s.should eq "This is a <mark>beautiful! morning</mark>"
      view.highlight("This is a beautiful? morning", "beautiful? morning").to_s.should eq "This is a <mark>beautiful? morning</mark>"
    end

    it "highlights accepts regexp" do
      view.highlight("This day was challenging for judge Allen and his colleagues.", /\ballen\b/i).to_s.should eq "This day was challenging for judge <mark>Allen</mark> and his colleagues."
    end

    it "highlights with multiple phrases in one pass" do
      view.highlight("wow em", %w(wow em), highlighter: "<em>\\1</em>").to_s.should eq %(<em>wow</em> <em>em</em>)
    end

    it "highlights with html" do
      view.highlight("<p>This is a beautiful morning, but also a beautiful day</p>", "beautiful").to_s.should eq "<p>This is a <mark>beautiful</mark> morning, but also a <mark>beautiful</mark> day</p>"
      view.highlight("<p>This is a <em>beautiful</em> morning, but also a beautiful day</p>", "beautiful").to_s.should eq "<p>This is a <em><mark>beautiful</mark></em> morning, but also a <mark>beautiful</mark> day</p>"
      view.highlight("<p>This is a <em class=\"error\">beautiful</em> morning, but also a beautiful <span class=\"last\">day</span></p>", "beautiful").to_s.should eq "<p>This is a <em class=\"error\"><mark>beautiful</mark></em> morning, but also a <mark>beautiful</mark> <span class=\"last\">day</span></p>"
      view.highlight("<p class=\"beautiful\">This is a beautiful morning, but also a beautiful day</p>", "beautiful").to_s.should eq "<p class=\"beautiful\">This is a <mark>beautiful</mark> morning, but also a <mark>beautiful</mark> day</p>"
      view.highlight("<p>This is a beautiful <a href=\"http://example.com/beautiful\#top?what=beautiful%20morning&when=now+then\">morning</a>, but also a beautiful day</p>", "beautiful").to_s.should eq "<p>This is a <mark>beautiful</mark> <a href=\"http://example.com/beautiful\#top?what=beautiful%20morning&when=now+then\">morning</a>, but also a <mark>beautiful</mark> day</p>"
      view.highlight("<div>abc div</div>", "div", highlighter: "<b>\\1</b>").to_s.should eq "<div>abc <b>div</b></div>"
    end

    it "highlights with block" do
      view.highlight("one two three", ["one", "two", "three"]) { |word| "<b>#{word}</b>" }.to_s.should eq "<b>one</b> <b>two</b> <b>three</b>"
      view.test_highlight.to_s.should eq "This is a <span data-highlight-word=\"beautiful\" data-color=\"yellow\" data-español=\"bello\">beautiful</span> morning, but also a <span data-highlight-word=\"beautiful\" data-color=\"yellow\" data-español=\"bello\">beautiful</span> day"
    end
  end
end
