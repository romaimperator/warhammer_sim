require "compute_hits"
require "hit_auditor"
require "compute_wounds"
require "wound_auditor"
require "compute_armor_save"
require "compute_ward_save"
require "die_roller"
require "attack_matchup_result"
require "equipment/auto_wound"
require "equipment/auto_hit"

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
    hits = compute_hits
    wounds = compute_wounds(hits)
    unsaved_wounds = roll_saves(wounds)
    AttackMatchupResult.new(@attack.number, hits, wounds, unsaved_wounds)
  end

  def compute_hits
    if !@attack.equipment.include?(Equipment::AutoHit.new)
      ComputeHits.new(@attack, @defend_stats.weapon_skill,
                      HitAuditor.new(@round_number, @attack)).compute
    else
      @attack.number
    end
  end

  def compute_wounds(hits)
    if !@attack.equipment.include?(Equipment::AutoWound.new)
      ComputeWounds.new(hits, @attack.strength, @defend_stats.toughness,
                        WoundAuditor.new(@round_number, @attack)).compute
    else
      hits
    end
  end

  def roll_armor_save(caused_wounds)
    caused_wounds -
      ComputeArmorSave.new(caused_wounds, @attack.strength,
                           @defend_stats.armor_save).compute
  end

  def roll_extra_save(caused_wounds)
    caused_wounds -
      ComputeWardSave.new(caused_wounds, @defend_stats.ward_save).compute
  end

  def roll_saves(caused_wounds)
    roll_extra_save(roll_armor_save(caused_wounds))
  end

  def ==(other)
    round_number == other.round_number &&
      attack  == other.attack
  end
end

