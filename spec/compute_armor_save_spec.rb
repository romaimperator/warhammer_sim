require "spec_helper"
require "compute_armor_save"

class TestArmorSaveAuditor
  def method_missing(method_name, first_arg, *args)
    first_arg
  end
end

describe ComputeArmorSave do
  describe "#raw_value_needed" do
    it "is not modified when the strength is 3 or less" do
      armor_save_roll = 5
      computer = ComputeArmorSave.new(3, 1, armor_save_roll, TestArmorSaveAuditor.new)
      assert_equal armor_save_roll, computer.raw_value_needed
      computer = ComputeArmorSave.new(3, 2, armor_save_roll, TestArmorSaveAuditor.new)
      assert_equal armor_save_roll, computer.raw_value_needed
      computer = ComputeArmorSave.new(3, 3, armor_save_roll, TestArmorSaveAuditor.new)
      assert_equal armor_save_roll, computer.raw_value_needed
    end

    [[4, 1],
     [5, 2],
     [6, 3],
     [7, 4],
     [8, 5],
     [9, 6],
     [10, 7]].each do |(strength, modifier)|
      it "is modified by #{modifier} when the strength is #{strength}" do
        armor_save_roll = 1
        computer = ComputeArmorSave.new(3, strength, armor_save_roll, TestArmorSaveAuditor.new)
        assert_equal armor_save_roll + modifier, computer.raw_value_needed
      end
    end
  end
end

