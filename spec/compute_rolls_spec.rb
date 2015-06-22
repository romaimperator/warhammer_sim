require "spec_helper"
require "compute_rolls"

class TestAuditor
  def method_missing(method_name, first_arg, *args)
    first_arg
  end
end

class ComputeRollsSubclass < ComputeRolls
  def raw_value_needed
    4
  end

  def number
    3
  end
end

describe ComputeRolls do
  subject { ComputeRollsSubclass.new(TestAuditor.new) }

  describe "#compute" do
    it "counts the number of values with a high enough number" do
      rolls = [1, 2, 4]
      allow(DieRoller).to receive(:roll_dice_and_reroll).and_return(rolls)
      assert_equal 1, subject.compute
    end
  end

  describe "#value_needed" do
    it "calls the auditor with the value_needed event" do
      value_needed = 4
      callback = spy
      computer = ComputeRollsSubclass.new(callback)
      computer.value_needed
      expect(callback).to have_received(:value_needed).with(value_needed)
    end

    it "returns the value returned by the auditor" do
      assert_equal 4, subject.value_needed
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

    it "calls a the auditor with the rolls event" do
      rolls = [1, 2, 3]
      allow(DieRoller).to receive(:roll_dice_and_reroll).and_return(rolls)
      callback = spy
      computer = ComputeRollsSubclass.new(callback)
      computer.rolls
      expect(callback).to have_received(:rolls).with(rolls)
    end

    it "returns the value returned by the auditor" do
      rolls = [1, 2, 6]
      allow(DieRoller).to receive(:roll_dice_and_reroll).and_return(rolls)
      assert_equal rolls, subject.rolls
    end
  end

  describe "#reroll" do
    it "calls the auditor with the reroll event" do
      value_needed = 4
      callback = TestAuditor.new
      allow(callback).to receive(:reroll_values)
      computer = ComputeRollsSubclass.new(callback)
      computer.reroll
      expect(callback).to have_received(:reroll_values).with([], value_needed)
    end

    it "returns the value returned by the auditor" do
      assert_equal [], subject.reroll
    end
  end
end

