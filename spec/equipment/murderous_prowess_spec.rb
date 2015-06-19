require "spec_helper"
require "equipment/murderous_prowess"

module Equipment
  describe MurderousProwess do
    describe "#wound_reroll_values" do
      it "adds one to the values that need to be rerolled" do
        item = MurderousProwess.new
        assert_equal [2, 1, 1], item.wound_reroll_values(1, [2, 1], 3)
      end
    end
  end
end

