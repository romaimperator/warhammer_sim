require "spec_helper"
require "equipment/fear"

module Equipment
  describe Fear do
    subject { Fear.new }

    def fail_leadership_roll
      allow(DieRoller).to receive(:sum_roll).and_return(9)
      unit = double(:unit, leadership: 8)
      subject.before_combat(1, unit, nil)
    end

    describe "#before_combat" do
      it "sets @failed_this_round when the unit fails its leadership test" do
        allow(DieRoller).to receive(:sum_roll).and_return(9)
        unit = double(:unit, leadership: 8)
        subject.before_combat(1, unit, nil)
        assert subject.failed_this_round
      end

      it "leaves @failed_this_round false when the unit passes" do
        allow(DieRoller).to receive(:sum_roll).and_return(8)
        unit = double(:unit, leadership: 8)
        subject.before_combat(1, unit, nil)
        refute subject.failed_this_round
      end
    end

    describe "#after_combat" do
      it "resets @failed_this_round to false" do
        fail_leadership_roll
        subject.after_combat(1, nil, nil)
        refute subject.failed_this_round
      end
    end

    describe "#weapon_skill" do
      it "does nothing if the test passed" do
        weapon_skill = 5
        assert_equal weapon_skill, subject.weapon_skill(1, weapon_skill)
      end

      it "returns 1 if the test failed" do
        fail_leadership_roll
        weapon_skill = 5
        assert_equal 1, subject.weapon_skill(1, weapon_skill)
      end
    end
  end
end
