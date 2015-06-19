require "spec_helper"
require "equipment"

module Equipment
  describe ExtraHandWeapon do
    subject { ExtraHandWeapon.new }

    describe "#attacks" do
      it "adds one to the current attack number" do
        assert_equal 5, subject.attacks(1, 4, nil, nil)
      end
    end
  end
end

