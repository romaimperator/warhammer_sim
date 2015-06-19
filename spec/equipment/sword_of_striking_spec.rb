require "spec_helper"
require "equipment/sword_of_striking"

module Equipment
  describe SwordOfStriking do
    describe "#hit_needed" do
      it "decreases the required hit number by 1" do
        assert_equal 3, SwordOfStriking.new.hit_needed(1, 4)
      end

      it "goes to a minimum of 2" do
        assert_equal 2, SwordOfStriking.new.hit_needed(1, 2)
      end
    end
  end
end

