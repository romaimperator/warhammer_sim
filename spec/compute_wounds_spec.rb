require "spec_helper"
require "compute_wounds"

class TestWoundAuditor
  def method_missing(method_name, first_arg, *args)
    first_arg
  end
end

describe ComputeWounds do
  describe "#raw_value_needed" do
    it "is 2 when the attack strength exceeds the defender toughness by 2 or more" do
      computer = ComputeWounds.new(1, 5, 3, TestWoundAuditor.new)
      assert_equal 2, computer.raw_value_needed
      computer = ComputeWounds.new(1, 6, 3, TestWoundAuditor.new)
      assert_equal 2, computer.raw_value_needed
    end

    it "is 3 when the attack strength exceeds the defender toughness by 1" do
      computer = ComputeWounds.new(1, 4, 3, TestWoundAuditor.new)
      assert_equal 3, computer.raw_value_needed
    end

    it "is 4 when the attack strength equals the defender toughness" do
      computer = ComputeWounds.new(1, 3, 3, TestWoundAuditor.new)
      assert_equal 4, computer.raw_value_needed
    end

    it "is 5 when the attack strength is 1 less than the defender toughness" do
      computer = ComputeWounds.new(1, 3, 4, TestWoundAuditor.new)
      assert_equal 5, computer.raw_value_needed
    end

    it "is 6 when the attack strength is 2 or more less than the defender toughness" do
      computer = ComputeWounds.new(1, 3, 5, TestWoundAuditor.new)
      assert_equal 6, computer.raw_value_needed
      computer = ComputeWounds.new(1, 3, 6, TestWoundAuditor.new)
      assert_equal 6, computer.raw_value_needed
    end
  end
end

