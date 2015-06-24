require "spec_helper"
require "compute_hits"
require "attack"

class TestHitAuditor
  def method_missing(method_name, first_arg, *args)
    first_arg
  end
end

describe ComputeHits do
  subject { ComputeHits.new(Attack.new(3, 3, 4, []), 3, TestHitAuditor.new) }

  describe "#raw_value_needed" do
    it "is 3 when the attack weapon skill exceeds the defender's" do
      computer = ComputeHits.new(Attack.new(1, 4, 4, []), 3, TestHitAuditor.new)
      assert_equal 3, computer.raw_value_needed
    end

    it "is 4 when the attack weapon skill equals the defender's" do
      computer = ComputeHits.new(Attack.new(1, 3, 4, []), 3, TestHitAuditor.new)
      assert_equal 4, computer.raw_value_needed
    end

    it "is 5 when the defender's weapon skill is more than twice the attacker's" do
      computer = ComputeHits.new(Attack.new(1, 2, 4, []), 5, TestHitAuditor.new)
      assert_equal 5, computer.raw_value_needed
    end
  end
end

