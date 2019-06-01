require "./text_helpers_spec"

describe Lucky::TextHelpers do
  describe "excerpt" do
    it "excerpts" do
      view.excerpt("This is a beautiful morning", "beautiful", radius: 5).should eq "...is a beautiful morn..."
      view.excerpt("This is a beautiful morning", "this", radius: 5).should eq "This is a..."
      view.excerpt("This is a beautiful morning", "morning", radius: 5).should eq "...iful morning"
      view.excerpt("This is a beautiful morning", "day").should eq ""
    end

    it "excerpts with regex" do
      view.excerpt("This is a beautiful! morning", "beautiful", radius: 5).should eq "...is a beautiful! mor..."
      view.excerpt("This is a beautiful? morning", "beautiful", radius: 5).should eq "...is a beautiful? mor..."
      view.excerpt("This is a beautiful? morning", /\bbeau\w*\b/i, radius: 5).should eq "...is a beautiful? mor..."
      view.excerpt("This is a beautiful? morning", /\b(beau\w*)\b/i, radius: 5).should eq "...is a beautiful? mor..."
      view.excerpt("This day was challenging for judge Allen and his colleagues.", /\ballen\b/i, radius: 5).should eq "...udge Allen and..."
      view.excerpt("This day was challenging for judge Allen and his colleagues.", /\ballen\b/i, radius: 1, separator: " ").should eq "...judge Allen and..."
      view.excerpt("This day was challenging for judge Allen and his colleagues.", /\b(\w*allen\w*)\b/i, radius: 5).should eq "...was challenging for..."
    end

    it "excerpts in borderline cases" do
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

    it "excerpts with omission" do
      view.excerpt("This is a beautiful morning", "beautiful", omission: "[...]", radius: 5).should eq "[...]is a beautiful morn[...]"
      view.excerpt("This is the ultimate supercalifragilisticexpialidoceous very looooooooooooooooooong looooooooooooong beautiful morning with amazing sunshine and awesome temperatures. So what are you gonna do about it?", "very", omission: "[...]").should eq "This is the ultimate supercalifragilisticexpialidoceous very looooooooooooooooooong looooooooooooong beautiful morning with amazing sunshine and awesome tempera[...]"
    end

    it "excerpts with separator" do
      view.excerpt("This is a very beautiful morning", "very", separator: " ", radius: 1).should eq "...a very beautiful..."
      view.excerpt("This is a very beautiful morning", "this", separator: " ", radius: 1).should eq "This is..."
      view.excerpt("This is a very beautiful morning", "morning", separator: " ", radius: 1).should eq "...beautiful morning"
      view.excerpt("my very\nvery\nvery long\nstring", "long", separator: "\n", radius: 0).should eq "...very long..."
      view.excerpt("my very\nvery\nvery long\nstring", "long", separator: "\n", radius: 1).should eq "...very\nvery long\nstring"
      view.excerpt("This is a beautiful morning", "a", separator: "").should eq view.excerpt("This is a beautiful morning", "a")
    end
  end
end
