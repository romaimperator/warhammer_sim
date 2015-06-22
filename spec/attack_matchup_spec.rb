require "spec_helper"
require "attack_matchup"
require "factories/attack_matchup_factory"
require "equipment/base" # needed to verify instance spy

describe AttackMatchup do
  subject { AttackMatchupFactory.new }

  describe "#compute_wounds" do
    it "returns a matchup result object" do
      assert_instance_of AttackMatchupResult, subject.build.attack
    end

    it "records results which make sense" do
      attack_count = 5
      matchup = subject.attack(Attack.new(attack_count, 3, 3, [])).build
      result  = matchup.attack
      assert_operator result.hits, :<=, attack_count
      assert_operator result.hits, :>=, 0
      assert_operator result.wounds_caused, :<=, attack_count
      assert_operator result.wounds_caused, :>=, 0
      assert_operator result.unsaved_wounds, :<=, attack_count
      assert_operator result.unsaved_wounds, :>=, 0
    end

    [:roll_hits,
     :roll_wounds,
     :hit_needed,
     :wound_needed,
     :hit_reroll_values,
     :wound_reroll_values,
    ].each do |callback|
      it "calls the #{callback} method on equipment" do
        item = Equipment::Base.new
        allow(item).to receive(callback).and_call_original
        subject.attack(Attack.new(5, 3, 3, [item])).build.attack
        expect(item).to have_received(callback).at_least(:once)
      end
    end

    it "skips the rolling phase if the weapon_skill is :auto_hit" do
      allow(subject).to receive(:roll_hits)
      result = subject.attack(Attack.new(5, :auto_hit, 3, [])).build.attack
      expect(subject).not_to have_received(:roll_hits)
      assert_equal 0, result.hits
    end
  end
end

