require "spec_helper"
require "equipment/reroll_wounds"

module Equipment
  describe RerollWounds do
    describe "#wound_reroll_values" do
      it "adds all the not-wounding values to the list to reroll" do
        assert_equal [1, 2, 3, 4], RerollWounds.new.wound_reroll_values(1, [], 5)
      end

      it "still adds them even if the values are already in the list" do
        assert_equal [1, 2, 1, 2, 3], RerollWounds.new.wound_reroll_values(1, [1, 2], 4)
      end
    end
  end
end

