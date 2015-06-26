require "spec_helper"
require "combat_resolution"
require "factories/rank_and_file_unit_factory"
require "attack_matchup_result"

describe CombatResolution do
  let(:attacker) { RankAndFileUnitFactory() }
  let(:defender) { RankAndFileUnitFactory() }
  let(:attacker_result) { AttackMatchupResult.new(0, 0, 0, 5) }
  let(:defender_result) { AttackMatchupResult.new(0, 0, 0, 1) }
  subject { CombatResolution.new(1, attacker, defender, attacker_result, defender_result) }

  describe "#compute" do
    describe "when there is a tie" do
      it "returns :tie" do
        defender_result = attacker_result
        combat_resolution = CombatResolution.new(1, attacker, defender, attacker_result, defender_result)
        assert_equal :tie, combat_resolution.compute
      end
    end

    describe "when the attacker is the winner" do
      it "calls the combat_round_lost hook on the loser's equipment" do
        allow(defender).to receive(:call_equipment_hook)
        subject.compute
        expect(defender).to have_received(:call_equipment_hook).with(:combat_round_lost, 1, defender)
      end

      describe "when the loser breaks" do
        before { allow(DieRoller).to receive(:sum_roll).and_return(12) } # Set the break test roll to 12

        it "removes the standard bearer" do
          allow(defender).to receive(:lose_standard_bearer)
          subject.compute
          expect(defender).to have_received(:lose_standard_bearer)
        end

        describe "when the loser is caught" do
          # Set the break test roll to 12, the pursuit roll to 10, and the flee roll to 3
          before { allow(DieRoller).to receive(:sum_roll).and_return(12, 10, 3) }

          it "returns :attacker_win" do
            assert_equal :attacker_win, subject.compute
          end

          it "destroys the loser" do
            allow(defender).to receive(:destroy)
            subject.compute
            expect(defender).to have_received(:destroy)
          end
        end

        describe "when the loser gets away" do
          # Set the break test roll to 12, the pursuit roll to 4, and the flee roll to 8
          before { allow(DieRoller).to receive(:sum_roll).and_return(12, 4, 8) }

          it "returns :defender_flee" do
            assert_equal :defender_flee, subject.compute
          end
        end
      end

      describe "when the loser does not break" do
        before { allow(DieRoller).to receive(:sum_roll).and_return(3) } # Set the break test roll to 3
        let(:attacker_result) { AttackMatchupResult.new(0, 0, 0, 2) } # Set the attacker to win by 1

        describe "when the loser is dead" do
          it "returns :attacker_win" do
            defender.destroy
            assert_equal :attacker_win, subject.compute
          end
        end

        describe "when the loser is not dead" do
          it "returns :defender_hold" do
            assert_equal :defender_hold, subject.compute
          end
        end
      end
    end
  end

  describe "#find_combat_winner" do
    it "returns the attacker as the winner if the resolution_difference is positive" do
      assert_equal [attacker, defender, :attacker_win, :defender_flee, :defender_hold],
                   subject.find_combat_winner
    end

    it "returns the defender as the winner if the resolution_difference is negative" do
      defender_result = AttackMatchupResult.new(0, 0, 0, 7)
      combat_resolution = CombatResolution.new(1, attacker, defender, attacker_result, defender_result)
      assert_equal [defender, attacker, :defender_win, :attacker_flee, :attacker_hold],
                   combat_resolution.find_combat_winner
    end
  end

  describe "#resolution_difference" do
    it "is the attacker's combat res minus the defender's combat res" do
      assert_equal 4, subject.resolution_difference
    end

    it "is negative if the defender wins" do
      defender_result = AttackMatchupResult.new(0, 0, 0, 7)
      combat_resolution = CombatResolution.new(1, attacker, defender, attacker_result, defender_result)
      assert_equal -2, combat_resolution.resolution_difference
    end
  end

  describe "#combat_resolution_earned" do
    it "is the sum of the unsaved wounds, rank_bonus, and standard_bearer bonus" do
      loser = instance_spy("RankAndFileUnit", has_standard?: true, number_of_ranks: 2)
      assert_equal 8, subject.combat_resolution_earned(loser, attacker_result)
    end
  end

  describe "#rank_bonus" do
    it "is the number of ranks" do
      loser = instance_spy("RankAndFileUnit", number_of_ranks: 2)
      assert_equal 2, subject.rank_bonus(loser)
    end

    it "is only to a max of three" do
      loser = instance_spy("RankAndFileUnit", number_of_ranks: 100)
      assert_equal 3, subject.rank_bonus(loser)
    end
  end

  describe "#standard_bearer" do
    it "returns 1 if the unit has a standard" do
      loser = instance_spy("RankAndFileUnit", has_standard?: true)
      assert_equal 1, subject.standard_bearer(loser)
    end

    it "returns 0 if the unit does not have a standard" do
      loser = instance_spy("RankAndFileUnit", has_standard?: false)
      assert_equal 0, subject.standard_bearer(loser)
    end
  end

  describe "#roll_break_test" do
    [[8..12, true],
     [2..7, false]].each do |(range, expected_result)|
      range.each do |roll|
        it "returns #{expected_result} when the loser rolls #{roll}" do
          allow(DieRoller).to receive(:sum_roll).and_return(roll)
          assert_equal expected_result, subject.roll_break_test(attacker, 0, defender)
        end
      end
    end

    it "does matter what the modifier is when the loser is not steadfast" do
      allow(attacker).to receive(:number_of_ranks).and_return(3)
      allow(defender).to receive(:number_of_ranks).and_return(3)
      allow(DieRoller).to receive(:sum_roll).and_return(3)
      assert_equal true, subject.roll_break_test(attacker, 100, defender)
    end

    it "doesn't matter what the modifier is when the loser is steadfast" do
      allow(attacker).to receive(:number_of_ranks).and_return(5)
      allow(defender).to receive(:number_of_ranks).and_return(3)
      allow(DieRoller).to receive(:sum_roll).and_return(3)
      assert_equal false, subject.roll_break_test(attacker, 100, defender)
    end

    it "calls the equipment roll_break_test function" do
      allow(DieRoller).to receive(:sum_roll).and_return(3)
      allow(attacker).to receive(:call_equipment).and_return(3)
      subject.roll_break_test(attacker, 100, defender)
      expect(attacker).to have_received(:call_equipment).with(:roll_break_test, 1, 3, 100)
    end
  end

  describe "#is_steadfast?" do
    it "is true if the loser has more ranks than the winner" do
      loser  = instance_spy("RankAndFileUnit", number_of_ranks: 3)
      winner = instance_spy("RankAndFileUnit", number_of_ranks: 2)
      assert_equal true, subject.is_steadfast?(loser, winner)
    end

    it "is false otherwise" do
      loser  = instance_spy("RankAndFileUnit", number_of_ranks: 3)
      winner = instance_spy("RankAndFileUnit", number_of_ranks: 3)
      assert_equal false, subject.is_steadfast?(loser, winner)
    end
  end

  describe "#check_break_test" do
    it "is true if the loser breaks by failing its leadership test" do
      roll = attacker.leadership + 1
      assert_equal true, subject.check_break_test(attacker, roll, 0)
    end

    it "is false if the roll is insane courage even if there is a modifier" do
      assert_equal false, subject.check_break_test(attacker, INSANE_COURAGE_ROLL, 100)
    end

    it "is false if the leadership test is passed" do
      roll = attacker.leadership
      assert_equal false, subject.check_break_test(attacker, roll, 0)
    end

    it "calls the equipment function for checking break tests" do
      loser = instance_spy("RankAndFileUnit", leadership: 7)
      subject.check_break_test(loser, 10, 0)
      expect(loser).to have_received(:call_equipment).with(:check_break_test, 1, true, 10, 0, loser)
    end
  end

  describe "#check_leadership_test" do
    it "is true when the roll is less than the leadership - the modifier" do
      loser = double(:unit, leadership: 7)
      roll = 5
      assert_equal true, subject.check_leadership_test(attacker, roll, 1)
    end

    it "is true when the roll equals leadership - the modifier" do
      loser = double(:unit, leadership: 7)
      roll = 4
      assert_equal true, subject.check_leadership_test(attacker, roll, 3)
    end

    it "is false when the roll exceeds leadership - the modifier" do
      loser = double(:unit, leadership: 7)
      roll = 6
      assert_equal false, subject.check_leadership_test(attacker, roll, 2)
    end
  end
end
