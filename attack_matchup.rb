require "compute_hits"
require "hit_auditor"
require "compute_wounds"
require "wound_auditor"
require "die_roller"
require "attack_matchup_result"

# This class is responsible for performing the attack and computing the number
# of hits, wounds, saves, and unsaved wounds.
class AttackMatchup
  attr_reader :round_number
  attr_reader :attack
  attr_reader :defender

  def initialize(round_number, attack, defender)
    @round_number = round_number
    @attack       = attack
    @defender     = defender
    @defend_stats = defender.defend_stats(round_number)
  end

  def attack
    hits = 0
    wounds = 0
    if @attack.weapon_skill != :auto_hit
      hits = compute_hits
      wounds = compute_wounds(hits)
    else
      wounds = compute_wounds(@attack.number)
    end
    unsaved_wounds = roll_saves(wounds)
    AttackMatchupResult.new(@attack.number, hits, wounds, unsaved_wounds)
  end

  def compute_hits
    ComputeHits.new(@attack, @defend_stats.weapon_skill,
                    HitAuditor.new(@round_number, @attack)).compute
  end

  def compute_wounds(hits)
    ComputeWounds.new(hits, @attack.strength, @defend_stats.toughness,
                      WoundAuditor.new(@round_number, @attack)).compute
  end

  def roll_armor_save(caused_wounds)
    save_modifier = @attack.strength > 3 ? @attack.strength - 3 : 0
    roll_needed = @defend_stats.armor_save + save_modifier

    caused_wounds - DieRoller.count_values_higher_than(DieRoller.roll_dice(caused_wounds),
                                                       roll_needed)
  end

  def roll_extra_save(caused_wounds)
    caused_wounds - DieRoller.count_values_higher_than(DieRoller.roll_dice(caused_wounds),
                                             @defend_stats.ward_save)
  end

  def roll_saves(caused_wounds)
    roll_extra_save(roll_armor_save(caused_wounds))
  end

  def ==(other)
    round_number == other.round_number &&
      attack  == other.attack
  end
end

