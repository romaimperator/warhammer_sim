#require File.expand_path(File.dirname(__FILE__) + "/../attack_matchup")
#require "factories/unit_factory"
#
#describe AttackMatchup do
#  describe "#attack" do
#  end
#
#  describe "#attacker_stats" do
#    it "calls the stats function on every item" do
#      round_number = 1
#      items = [double, double]
#      attacker = UnitFactory.new.equipment(items).build
#      items.each do |item|
#        item.should_receive(:stats)
#      end
#      matchup = AttackMatchup.new(round_number, attacker, nil)
#      matchup.attacker_stats
#    end
#  end
#
#  describe "#compute_wounds" do
#  end
#
#  describe "#defender_stats" do
#    it "calls the stats function on every item" do
#      round_number = 1
#      items = [double, double]
#      defender = UnitFactory.new.equipment(items).build
#      items.each do |item|
#        item.should_receive(:stats)
#      end
#      matchup = AttackMatchup.new(round_number, nil, defender)
#      matchup.defender_stats
#    end
#  end
#
#  describe "#hit_reroll_values" do
#  end
#
#  describe "#number_of_attacks" do
#  end
#
#  describe "#roll_armor_save" do
#  end
#end

