require "spec_helper"
require "compute_ward_save"

describe ComputeWardSave do
  describe "#raw_value_needed" do
    it "is the defender ward save" do
      ward_save = 5
      computer = ComputeWardSave.new(3, ward_save)
      assert_equal ward_save, computer.raw_value_needed
    end
  end
end

