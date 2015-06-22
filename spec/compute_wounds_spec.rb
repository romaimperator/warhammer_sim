require "spec_helper"
require "compute_wounds"

class TestWoundAuditor
  def method_missing(method_name, first_arg, *args)
    first_arg
  end
end

describe ComputeWounds do
  let(:hits) { 3 }
  subject { ComputeWounds.new(hits, 3, 3, TestWoundAuditor.new) }

  describe "#compute" do
    it "counts the number of wounds" do
      rolls = [1, 2, 5]
      allow(DieRoller).to receive(:roll_dice_and_reroll).and_return(rolls)
      assert_equal 1, subject.compute
    end
  end

  describe "#wound_needed" do
    it "calls the auditor with the wound_needed event" do
      wound_needed = 4
      callback = spy
      computer = ComputeWounds.new(1, 3, 3, callback)
      computer.wound_needed
      expect(callback).to have_received(:wound_needed).with(wound_needed)
    end

    it "returns the value returned by the auditor" do
      assert_equal 4, subject.wound_needed
    end
  end

  describe "#raw_wound_needed" do
    it "is 2 when the attack strength exceeds the defender toughness by 2 or more" do
      computer = ComputeWounds.new(1, 5, 3, TestWoundAuditor.new)
      assert_equal 2, computer.raw_wound_needed
      computer = ComputeWounds.new(1, 6, 3, TestWoundAuditor.new)
      assert_equal 2, computer.raw_wound_needed
    end

    it "is 3 when the attack strength exceeds the defender toughness by 1" do
      computer = ComputeWounds.new(1, 4, 3, TestWoundAuditor.new)
      assert_equal 3, computer.raw_wound_needed
    end

    it "is 4 when the attack strength equals the defender toughness" do
      computer = ComputeWounds.new(1, 3, 3, TestWoundAuditor.new)
      assert_equal 4, computer.raw_wound_needed
    end

    it "is 5 when the attack strength is 1 less than the defender toughness" do
      computer = ComputeWounds.new(1, 3, 4, TestWoundAuditor.new)
      assert_equal 5, computer.raw_wound_needed
    end

    it "is 6 when the attack strength is 2 or more less than the defender toughness" do
      computer = ComputeWounds.new(1, 3, 5, TestWoundAuditor.new)
      assert_equal 6, computer.raw_wound_needed
      computer = ComputeWounds.new(1, 3, 6, TestWoundAuditor.new)
      assert_equal 6, computer.raw_wound_needed
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

    it "calls a the auditor with the roll_wounds event" do
      rolls = [1, 2, 3]
      allow(DieRoller).to receive(:roll_dice_and_reroll).and_return(rolls)
      callback = spy
      computer = ComputeWounds.new(1, 3, 3, callback)
      computer.rolls
      expect(callback).to have_received(:roll_wounds).with(rolls)
    end

    it "returns the value returned by the auditor" do
      rolls = [1, 2, 6]
      allow(DieRoller).to receive(:roll_dice_and_reroll).and_return(rolls)
      assert_equal rolls, subject.rolls
    end
  end

  describe "#reroll" do
    it "calls the auditor with the reroll event" do
      wound_needed = 4
      callback = TestWoundAuditor.new
      allow(callback).to receive(:wound_reroll_values)
      computer = ComputeWounds.new(1, 3, 3, callback)
      computer.reroll
      expect(callback).to have_received(:wound_reroll_values).with([], wound_needed)
    end

    it "returns the value returned by the auditor" do
      assert_equal [], subject.reroll
    end
  end
end

