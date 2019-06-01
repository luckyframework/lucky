require "./text_helpers_spec"

describe Lucky::TextHelpers do
  Spec.before_each do
    view.reset_cycles
  end

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
      view.cycle("one", 2, "3").should eq "one"
      view.cycle("one", 2, "3").should eq "2"
      view.cycle("one", 2, "3").should eq "3"
      view.cycle("one", 2, "3").should eq "one"
      view.cycle("one", 2, "3").should eq "2"
      view.cycle("one", 2, "3").should eq "3"
    end

    it "cycles with array" do
      array = [1, 2, 3]
      view.cycle(array).should eq "1"
      view.cycle(array).should eq "2"
      view.cycle(array).should eq "3"
    end

    it "cycle resets with new values" do
      view.cycle("even", "odd").should eq "even"
      view.cycle("even", "odd").should eq "odd"
      view.cycle("even", "odd").should eq "even"
      view.cycle(1, 2, 3).should eq "1"
      view.cycle(1, 2, 3).should eq "2"
      view.cycle(1, 2, 3).should eq "3"
      view.cycle(1, 2, 3).should eq "1"
    end

    it "cycles named cycles" do
      view.cycle(1, 2, 3, name: "numbers").should eq "1"
      view.cycle("red", "blue", name: "colors").should eq "red"
      view.cycle(1, 2, 3, name: "numbers").should eq "2"
      view.cycle("red", "blue", name: "colors").should eq "blue"
      view.cycle(1, 2, 3, name: "numbers").should eq "3"
      view.cycle("red", "blue", name: "colors").should eq "red"
    end

    it "gets current cycle with default name" do
      view.cycle("even", "odd")
      view.current_cycle.should eq "even"
      view.cycle("even", "odd")
      view.current_cycle.should eq "odd"
      view.cycle("even", "odd")
      view.current_cycle.should eq "even"
    end

    it "gets current cycle with named cycles" do
      view.cycle("red", "blue", name: "colors")
      view.current_cycle("colors").should eq "red"
      view.cycle("red", "blue", name: "colors")
      view.current_cycle("colors").should eq "blue"
      view.cycle("red", "blue", name: "colors")
      view.current_cycle("colors").should eq "red"
    end

    it "gets current cycle with no exceptions" do
      view.current_cycle.should be_nil
      view.current_cycle("colors").should be_nil
    end

    it "gets current cycle with more than two names" do
      view.cycle(1, 2, 3)
      view.current_cycle.should eq "1"
      view.cycle(1, 2, 3)
      view.current_cycle.should eq "2"
      view.cycle(1, 2, 3)
      view.current_cycle.should eq "3"
      view.cycle(1, 2, 3)
      view.current_cycle.should eq "1"
    end

    it "cycles with default named" do
      view.cycle(1, 2, 3).should eq "1"
      view.cycle(1, 2, 3, name: "default").should eq "2"
      view.cycle(1, 2, 3).should eq "3"
    end

    it "resets cycle" do
      view.cycle(1, 2, 3).should eq "1"
      view.cycle(1, 2, 3).should eq "2"
      view.reset_cycle
      view.cycle(1, 2, 3).should eq "1"
    end

    it "resets unknown cycle" do
      view.reset_cycle("colors")
    end

    it "resets named cycle" do
      view.cycle(1, 2, 3, name: "numbers").should eq "1"
      view.cycle("red", "blue", name: "colors").should eq "red"
      view.reset_cycle("numbers")
      view.cycle(1, 2, 3, name: "numbers").should eq "1"
      view.cycle("red", "blue", name: "colors").should eq "blue"
      view.cycle(1, 2, 3, name: "numbers").should eq "2"
      view.cycle("red", "blue", name: "colors").should eq "red"
    end
  end
end
