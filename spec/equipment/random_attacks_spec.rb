require "spec_helper"
require "equipment/random_attacks"

module Equipment
  describe RandomAttacks do
    describe "#attacks" do
      it "adds a random number of attacks" do
        item = RandomAttacks.new(1)
        allow(DieRoller).to receive(:sum_roll).and_return(2)
        assert_equal 3, item.attacks(1, 1, nil, 1)
      end

      it "rolls the number of dice as configured" do
        allow(DieRoller).to receive(:sum_roll).and_return(2)
        dice_to_roll = 2
        item = RandomAttacks.new(dice_to_roll)
        item.attacks(1, 1, nil, 1)
        expect(DieRoller).to have_received(:sum_roll).with(dice_to_roll)
      end
    end
  end
end

