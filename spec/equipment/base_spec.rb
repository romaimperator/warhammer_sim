require "spec_helper"
require "equipment/base"

module Equipment
  describe Base do
    subject { Base.new }

    # Leaving out of testing the hooks since they by definition do nothing

    describe "#hit_needed" do
      it "passes through the needed roll value" do
        assert_equal 3, subject.hit_needed(1, 3)
      end
    end

    describe "#wound_needed" do
      it "passes through the needed roll value" do
        assert_equal 3, subject.wound_needed(1, 3)
      end
    end

    describe "#hit_reroll_values" do
      it "passes through the reroll values" do
        assert_equal [1, 4], subject.hit_reroll_values(1, [1, 4], 3)
      end
    end

    describe "#wound_reroll_values" do
      it "passes through the reroll values" do
        assert_equal [1, 4], subject.wound_reroll_values(1, [1, 4], 3)
      end
    end

    describe "#roll_hits" do
      it "passes through the rolled numbers" do
        assert_equal [2, 6, 4], subject.roll_hits(1, [2, 6, 4])
      end
    end

    describe "#roll_wounds" do
      it "passes through the rolled numbers" do
        assert_equal [3, 5, 6, 4], subject.roll_wounds(1, [3, 5, 6, 4])
      end
    end

    describe "#weapon_skill" do
      it "passes through the current value" do
        assert_equal 5, subject.weapon_skill(1, 5)
      end
    end

    describe "#strength" do
      it "passes through the current value" do
        assert_equal 5, subject.strength(1, 5)
      end
    end

    describe "#toughness" do
      it "passes through the current value" do
        assert_equal 5, subject.toughness(1, 5)
      end
    end

    describe "#wounds" do
      it "passes through the current value" do
        assert_equal 5, subject.wounds(1, 5)
      end
    end

    describe "#initiative" do
      it "passes through the current value" do
        assert_equal 5, subject.initiative(1, 5)
      end
    end

    describe "#attacks" do
      it "passes through the current value" do
        assert_equal 3, subject.attacks(1, 3, nil, 1)
      end
    end

    describe "#leadership" do
      it "passes through the current value" do
        assert_equal 5, subject.leadership(1, 5)
      end
    end

    describe "#armor_save" do
      it "passes through the current value" do
        assert_equal 5, subject.armor_save(1, 5)
      end
    end

    describe "#ward_save" do
      it "passes through the current value" do
        assert_equal 5, subject.ward_save(1, 5)
      end
    end

    describe "#roll_break_test" do
      it "passes through the current value" do
        assert_equal 5, subject.roll_break_test(1, 5, 1)
      end
    end

    describe "#check_break_test" do
      it "passes through the current value" do
        assert subject.check_break_test(1, true, 4, 1, nil)
      end
    end

    describe "#taken_wounds" do
      it "passes through the current value" do
        assert_equal 4, subject.taken_wounds(1, 4)
      end
    end

    describe "#initiative_steps" do
      it "passes through the current value" do
        assert_equal [2, 3], subject.initiative_steps(1, [2, 3])
      end
    end

    describe "#matchups_for_initiative" do
      it "passes through the current value" do
        matchup = double(:matchup)
        assert_equal [matchup], subject.matchups_for_initiative(1, [matchup], 3, 2, nil)
      end
    end

    describe "#pending_attacks" do
      it "passes through the current value" do
        attack = double(:attack)
        assert_equal [attack], subject.pending_attacks(1, [attack], 3)
      end
    end
  end
end

