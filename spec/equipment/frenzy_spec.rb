require "spec_helper"
require "equipment/frenzy"

module Equipment
  describe Frenzy do
    subject { Frenzy.new }

    describe "#combat_round_lost" do
      it "removes itself from the owner's equipment list" do
        owner = instance_spy("RankAndFileUnit")
        subject.owner = owner
        subject.combat_round_lost(1, nil)
        expect(owner).to have_received(:remove_equipment).with(subject)
      end
    end

    describe "#attacks" do
      it "adds an attack to the current number" do
        assert_equal 5, subject.attacks(1, 4, nil, nil)
      end
    end
  end
end

