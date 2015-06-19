require "spec_helper"
require "equipment/minus_to_hit"

module Equipment
  describe MinusToHit do
    describe "#hit_needed" do
      it "applies the given penalty to the to hit roll" do
        penalty = 1
        minus = MinusToHit.new(penalty)
        assert_equal 5, minus.hit_needed(1, 4)
      end

      it "goes to a maximum to hit of 6+" do
        penalty = 10
        minus = MinusToHit.new(penalty)
        assert_equal 6, minus.hit_needed(1, 4)
      end
    end
  end
end

