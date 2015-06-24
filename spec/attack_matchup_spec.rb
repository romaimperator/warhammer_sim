require "spec_helper"
require "attack_matchup"
require "factories/attack_matchup_factory"
require "equipment/base" # needed to verify instance spy
require "equipment/auto_wound"
require "equipment/auto_hit"

describe AttackMatchup do
  subject { AttackMatchupFactory.new }

  describe "#attack" do
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
      result = subject.attack(Attack.new(5, 3, 3, [Equipment::AutoHit.new])).build.attack
      assert_equal 5, result.hits
    end
  end

  describe "#compute_hits" do
    it "computes hits normally" do
      allow(ComputeHits).to receive(:new).and_return(double.as_null_object)
      matchup = subject.attack(Attack.new(4, 3, 3, [])).build
      matchup.compute_hits
      expect(ComputeHits).to have_received(:new)
    end

    it "returns hits as same as attacks when the weapon skill is :auto_hit" do
      attack_count = 4
      matchup = subject.attack(Attack.new(attack_count, 3, 3, [Equipment::AutoHit.new])).build
      assert_equal attack_count, matchup.compute_hits
    end
  end

  describe "#compute_wounds" do
    it "computes wounds normally" do
      allow(ComputeWounds).to receive(:new).and_return(double.as_null_object)
      subject.build.compute_wounds(4)
      expect(ComputeWounds).to have_received(:new)
    end

    it "returns wounds as same as hits when the attack includes AutoWound" do
      hits = 4
      matchup = subject.attack(Attack.new(1, 3, 3, [Equipment::AutoWound.new])).build
      assert_equal hits, matchup.compute_wounds(hits)
    end
  end

  describe "#roll_armor_save" do
  end

  describe "#roll_extra_save" do
  end
end

