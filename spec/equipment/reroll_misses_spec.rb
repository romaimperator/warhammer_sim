require "spec_helper"
require "equipment/reroll_misses"

module Equipment
  describe RerollMisses do
    subject { RerollMisses.new }

    describe "#hit_reroll_values" do
      it "adds the values that correspond to a miss to the reroll values" do
        assert_equal [1, 2, 3], subject.hit_reroll_values(2, [], 4)
        assert_equal [1, 2, 3, 4, 5], subject.hit_reroll_values(2, [], 6)
      end
    end
  end
end

