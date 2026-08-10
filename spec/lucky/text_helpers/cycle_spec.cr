require "./text_helpers_spec"

describe Lucky::TextHelpers do
  describe "cycle" do
    describe Lucky::TextHelpers::Cycle do
      it "cycles when converted to a string" do
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

    it "cycles" do
      page = view
      page.cycle("one", 2, "3").should eq "one"
      page.cycle("one", 2, "3").should eq "2"
      page.cycle("one", 2, "3").should eq "3"
      page.cycle("one", 2, "3").should eq "one"
      page.cycle("one", 2, "3").should eq "2"
      page.cycle("one", 2, "3").should eq "3"
    end

    it "cycles with array" do
      page = view
      array = [1, 2, 3]
      page.cycle(array).should eq "1"
      page.cycle(array).should eq "2"
      page.cycle(array).should eq "3"
    end

    it "keeps cycles isolated between pages" do
      first_page = view
      second_page = view

      first_page.cycle("even", "odd").should eq "even"
      second_page.cycle("even", "odd").should eq "even"
    end

    it "cycle resets with new values" do
      page = view
      page.cycle("even", "odd").should eq "even"
      page.cycle("even", "odd").should eq "odd"
      page.cycle("even", "odd").should eq "even"
      page.cycle(1, 2, 3).should eq "1"
      page.cycle(1, 2, 3).should eq "2"
      page.cycle(1, 2, 3).should eq "3"
      page.cycle(1, 2, 3).should eq "1"
    end

    it "cycles named cycles" do
      page = view
      page.cycle(1, 2, 3, name: "numbers").should eq "1"
      page.cycle("red", "blue", name: "colors").should eq "red"
      page.cycle(1, 2, 3, name: "numbers").should eq "2"
      page.cycle("red", "blue", name: "colors").should eq "blue"
      page.cycle(1, 2, 3, name: "numbers").should eq "3"
      page.cycle("red", "blue", name: "colors").should eq "red"
    end

    it "gets current cycle with default name" do
      page = view
      page.cycle("even", "odd")
      page.current_cycle.should eq "even"
      page.cycle("even", "odd")
      page.current_cycle.should eq "odd"
      page.cycle("even", "odd")
      page.current_cycle.should eq "even"
    end

    it "gets current cycle with named cycles" do
      page = view
      page.cycle("red", "blue", name: "colors")
      page.current_cycle("colors").should eq "red"
      page.cycle("red", "blue", name: "colors")
      page.current_cycle("colors").should eq "blue"
      page.cycle("red", "blue", name: "colors")
      page.current_cycle("colors").should eq "red"
    end

    it "gets current cycle with no exceptions" do
      page = view
      page.current_cycle.should be_nil
      page.current_cycle("colors").should be_nil
    end

    it "gets current cycle with more than two names" do
      page = view
      page.cycle(1, 2, 3)
      page.current_cycle.should eq "1"
      page.cycle(1, 2, 3)
      page.current_cycle.should eq "2"
      page.cycle(1, 2, 3)
      page.current_cycle.should eq "3"
      page.cycle(1, 2, 3)
      page.current_cycle.should eq "1"
    end

    it "cycles with default named" do
      page = view
      page.cycle(1, 2, 3).should eq "1"
      page.cycle(1, 2, 3, name: "default").should eq "2"
      page.cycle(1, 2, 3).should eq "3"
    end

    it "resets cycle" do
      page = view
      page.cycle(1, 2, 3).should eq "1"
      page.cycle(1, 2, 3).should eq "2"
      page.reset_cycle
      page.cycle(1, 2, 3).should eq "1"
    end

    it "resets unknown cycle" do
      page = view
      page.reset_cycle("colors")
    end

    it "resets named cycle" do
      page = view
      page.cycle(1, 2, 3, name: "numbers").should eq "1"
      page.cycle("red", "blue", name: "colors").should eq "red"
      page.reset_cycle("numbers")
      page.cycle(1, 2, 3, name: "numbers").should eq "1"
      page.cycle("red", "blue", name: "colors").should eq "blue"
      page.cycle(1, 2, 3, name: "numbers").should eq "2"
      page.cycle("red", "blue", name: "colors").should eq "red"
    end
  end
end
