require "spec_helper"
require "round"
require "factories/rank_and_file_unit_factory"

describe Round do
  describe "#build_matchups" do
    it "is a list of AttackMatchups with attacker at given initiative" do
      attacker = double("attacker")
      defender = double("defender")
      allow(attacker).to receive(:build_matchups2)
      allow(defender).to receive(:build_matchups2)
      round = Round.new(1, attacker, defender)
      round.build_matchups(5)
      expect(attacker).to have_received(:build_matchups2).with(1, 5, defender)
      expect(defender).to have_received(:build_matchups2).with(1, 5, attacker)
    end
  end

  describe "#initiative_steps" do
    it "returns a set of initiative values of both attacker and defender" do
      attacker = double("attacker", initiative_steps: [1, 4])
      defender = double("defender", initiative_steps: [2, 4])
      assert_equal [1, 2, 4], Round.new(1, attacker, defender).initiative_steps
    end
  end

  describe "#simulate" do
    it "returns a RoundResult object" do
      attacker = RankAndFileUnitFactory()
      defender = RankAndFileUnitFactory()
      round = Round.new(1, attacker, defender)
      assert_instance_of RoundResult, round.simulate
    end

    it "calls the before_combat hooks" do
      item_a = Equipment::Base.new
      item_b = Equipment::Base.new
      allow(item_a).to receive(:before_combat)
      allow(item_b).to receive(:before_combat)
      attacker = RankAndFileUnitFactory(equipment: [item_a])
      defender = RankAndFileUnitFactory(equipment: [item_b])
      round = Round.new(1, attacker, defender)
      round.simulate
      expect(item_a).to have_received(:before_combat)
      expect(item_b).to have_received(:before_combat)
    end

    it "calls the after_combat hooks" do
      item_a = Equipment::Base.new
      item_b = Equipment::Base.new
      allow(item_a).to receive(:after_combat)
      allow(item_b).to receive(:after_combat)
      attacker = RankAndFileUnitFactory(equipment: [item_a])
      defender = RankAndFileUnitFactory(equipment: [item_b])
      round = Round.new(1, attacker, defender)
      round.simulate
      expect(item_a).to have_received(:after_combat)
      expect(item_b).to have_received(:after_combat)
    end
  end

  describe "#compute_outcome" do
    it "returns :both_dead if both units are dead" do
      attacker = double("attacker", dead?: true)
      defender = double("defender", dead?: true)
      round = Round.new(1, attacker, defender)
      assert_equal :both_dead, round.compute_outcome(attacker, defender, nil, nil)
    end

    it "returns :attacker_win if the defender is dead" do
      attacker = double("attacker", dead?: false)
      defender = double("defender", dead?: true)
      round = Round.new(1, attacker, defender)
      assert_equal :attacker_win, round.compute_outcome(attacker, defender, nil, nil)
    end

    it "returns :defender_win if the attacker is dead" do
      attacker = double("attacker", dead?: true)
      defender = double("defender", dead?: false)
      round = Round.new(1, attacker, defender)
      assert_equal :defender_win, round.compute_outcome(attacker, defender, nil, nil)
    end

    it "delegates out to the CombatResolution class if neither unit is dead" do
      attacker = double("attacker", dead?: false)
      defender = double("defender", dead?: false)
      round = Round.new(1, attacker, defender)
      allow(CombatResolution).to receive(:new).and_return(combat_resolution = double(:combat, compute: true))
      round.compute_outcome(attacker, defender, nil, nil)
      expect(combat_resolution).to have_received(:compute)
    end
  end

  describe "#run_before_combat_hooks" do
    it "calls the equipment hook on both units" do
      attacker = double("attacker")
      defender = double("defender")
      allow(attacker).to receive(:call_equipment_hook)
      allow(defender).to receive(:call_equipment_hook)
      round = Round.new(1, attacker, defender)
      round.run_before_combat_hooks
      expect(attacker).to have_received(:call_equipment_hook).with(:before_combat, 1, attacker, defender)
      expect(defender).to have_received(:call_equipment_hook).with(:before_combat, 1, defender, attacker)
    end
  end

  describe "#run_after_combat_hooks" do
    it "calls the equipment hook on both units" do
      attacker = double("attacker")
      defender = double("defender")
      allow(attacker).to receive(:call_equipment_hook)
      allow(defender).to receive(:call_equipment_hook)
      round = Round.new(1, attacker, defender)
      round.run_after_combat_hooks
      expect(attacker).to have_received(:call_equipment_hook).with(:after_combat, 1, attacker, defender)
      expect(defender).to have_received(:call_equipment_hook).with(:after_combat, 1, defender, attacker)
    end
  end
end
