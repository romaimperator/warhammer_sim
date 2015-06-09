require "spec_helper"
require_relative "../round"

describe Round do
  describe "#initiative_steps" do
    it "returns a set of initiative values of both attacker and defender" do
      attacker = double("attacker", initiative_steps: [1, 4])
      defender = double("defender", initiative_steps: [2, 4])
      assert_equal [1, 2, 4], Round.new(1, attacker, defender).initiative_steps
    end
  end

  describe "#build_matchups" do
    it "is a list of AttackMatchups with attacker at given initiative" do
      attacker = double("attacker")
      defender = double("defender")
      expect(attacker).to receive(:units_with_initiative).with(5) { [attacker] }
      expect(defender).to receive(:units_with_initiative).with(5) { [] }
      round = Round.new(1, attacker, defender)
      assert_equal [AttackMatchup.new(1, attacker, defender)],
                   round.build_matchups(5)
    end
  end
end

