require "spec_helper"
require "equipment/stomp_attack"

module Equipment
  describe StompAttack do
    subject { StompAttack.new }

    describe "#initiative_steps" do
      it "adds the always strike last initiative value to the list" do
        assert_includes subject.initiative_steps(1, []), ALWAYS_STRIKE_LAST_INITIATIVE_VALUE
      end

      it "does not add a duplicate" do
        values = [ALWAYS_STRIKE_LAST_INITIATIVE_VALUE, 2]
        assert_equal values, subject.initiative_steps(1, values)
      end
    end

    describe "#pending_attacks" do
      it "adds one auto-hitting attack if initiative value is always strike last" do
        owner = instance_spy("RankAndFileUnit")
        subject.owner = owner
        # expect the attack (owner because of the return value of the spy)
        assert_equal [owner], subject.pending_attacks(1, [], ALWAYS_STRIKE_LAST_INITIATIVE_VALUE)
        expect(owner).to have_received(:make_attack).with(round_number: 1, number: 1,
                                                          weapon_skill: :auto_hit,
                                                          equipment: [])
      end

      it "does nothing if a different initiative value" do
        current_attack = double(:attack)
        assert_equal [current_attack], subject.pending_attacks(1, [current_attack], 5)
      end
    end
  end
end

