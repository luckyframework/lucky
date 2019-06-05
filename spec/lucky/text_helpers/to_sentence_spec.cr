require "./text_helpers_spec"

class CustomEnumerable
  include Enumerable(Int32)

  def each
    yield 1
    yield 2
    yield 3
  end
end

describe Lucky::TextHelpers do
  describe "to_sentence" do
    it "correctly handles an empty list" do
      list = [] of String

      view.to_sentence(list).should eq ""
    end

    it "correctly handles a list of one" do
      list = ["cat"]

      view.to_sentence(list).should eq "cat"
    end

    it "creates a sentence from a list of two" do
      list = ["cat", "dog"]

      view.to_sentence(list).should eq "cat and dog"
    end

    it "creates a sentence from a list of three or more" do
      list = ["cat", "dog", "elephant", "fox"]

      view.to_sentence(list).should eq "cat, dog, elephant, and fox"
    end

    it "works correctly when the list is a tuple" do
      list = {"cat", "dog", "elephant"}

      view.to_sentence(list).should eq "cat, dog, and elephant"
    end

    it "works correctly when the list is a custom enumerable" do
      list = CustomEnumerable.new

      view.to_sentence(list).should eq "1, 2, and 3"
    end

    it "uses the provided word connector when given" do
      list = {"cat", "dog", "elephant", "fox"}

      view.to_sentence(list, word_connector: " + ").should eq "cat + dog + elephant, and fox"
    end

    it "uses the provided two word connector when given" do
      list = {"cat", "dog"}

      view.to_sentence(list, two_word_connector: " with ").should eq "cat with dog"
    end

    it "uses the provided last word connector when given" do
      list = {"cat", "dog", "elephant"}

      view.to_sentence(list, last_word_connector: ", or ").should eq "cat, dog, or elephant"
    end
  end
end
