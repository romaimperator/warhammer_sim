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

  describe "#compute" do
    it "counts the number of hits" do
      rolls = [1, 2, 4]
      allow(DieRoller).to receive(:roll_dice_and_reroll).and_return(rolls)
      assert_equal 1, subject.compute
    end
  end

  describe "#hit_needed" do
    it "calls the auditor with the hit_needed event" do
      hit_needed = 4
      callback = spy
      computer = ComputeHits.new(Attack.new(3, 3, 4, []), 3, callback)
      computer.hit_needed
      expect(callback).to have_received(:hit_needed).with(hit_needed)
    end

    it "returns the value returned by the auditor" do
      assert_equal 4, subject.hit_needed
    end
  end

  describe "#raw_hit_needed" do
    it "is 3 when the attack weapon skill exceeds the defender's" do
      computer = ComputeHits.new(Attack.new(1, 4, 4, []), 3, TestHitAuditor.new)
      assert_equal 3, computer.raw_hit_needed
    end

    it "is 4 when the attack weapon skill equals the defender's" do
      computer = ComputeHits.new(Attack.new(1, 3, 4, []), 3, TestHitAuditor.new)
      assert_equal 4, computer.raw_hit_needed
    end

    it "is 5 when the defender's weapon skill is more than twice the attacker's" do
      computer = ComputeHits.new(Attack.new(1, 2, 4, []), 5, TestHitAuditor.new)
      assert_equal 5, computer.raw_hit_needed
    end
  end

  describe "#rolls" do
    it "rolls the correct number of dice" do
      allow(DieRoller).to receive(:roll_dice).and_return([1, 3, 4])
      subject.rolls
      expect(DieRoller).to have_received(:roll_dice).with(3)
    end

    it "also incorporates rerolling" do
      allow(DieRoller).to receive(:roll_dice_and_reroll).and_return([2, 3, 6])
      subject.rolls
      expect(DieRoller).to have_received(:roll_dice_and_reroll).with(3, 4, [])
    end

    it "calls a the auditor with the roll_hits event" do
      rolls = [1, 2, 3]
      allow(DieRoller).to receive(:roll_dice_and_reroll).and_return(rolls)
      callback = spy
      computer = ComputeHits.new(Attack.new(3, 3, 4, []), 3, callback)
      computer.rolls
      expect(callback).to have_received(:roll_hits).with(rolls)
    end

    it "returns the value returned by the auditor" do
      rolls = [1, 2, 6]
      allow(DieRoller).to receive(:roll_dice_and_reroll).and_return(rolls)
      assert_equal rolls, subject.rolls
    end
  end

  describe "#reroll" do
    it "calls the auditor with the reroll event" do
      hit_needed = 4
      callback = TestHitAuditor.new
      allow(callback).to receive(:hit_reroll_values)
      computer = ComputeHits.new(Attack.new(3, 3, 4, []), 3, callback)
      computer.reroll
      expect(callback).to have_received(:hit_reroll_values).with([], hit_needed)
    end

    it "returns the value returned by the auditor" do
      assert_equal [], subject.reroll
    end
  end
end

