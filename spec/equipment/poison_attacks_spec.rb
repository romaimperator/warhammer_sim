require "spec_helper"
require "equipment/poison_attacks"

module Equipment
  describe PoisonAttacks do
    subject { PoisonAttacks.new }

    it "saves off any 6s as poison hits and adds them back in to the wound rolls" do
      rolls = [1, 2, 6, 3, 4, 5, 6]
      modified_rolls = subject.roll_hits(1, rolls)
      assert_equal [1, 2, 3, 4, 5, 6, 6], subject.roll_wounds(1, modified_rolls)
    end
  end
end

