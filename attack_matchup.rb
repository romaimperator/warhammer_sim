require "compute_wounds"
require "compute_hits"
require "compute_hit_needed"
require "compute_wound_needed"
require "attack_matchup_result"
require "die_roller"

# This class is responsible for performing the attack and computing the number
# of hits, wounds, saves, and unsaved wounds.
class AttackMatchup
  attr_reader :round_number
  attr_reader :attacker
  attr_reader :attacks
  attr_reader :defender

  def initialize(round_number, attacker, attacks, defender)
    @round_number = round_number
    @attacker = attacker
    @attacks  = attacks
    @defender = defender
    @attack_stats = attacker.attack_stats(round_number)
    @defend_stats = defender.defend_stats(round_number)
  end

  def attack
    compute_wounds
  end

  def compute_wounds
    hits = roll_hits
    wounds = roll_wounds(hits)
    unsaved_wounds = roll_saves(wounds)
    AttackMatchupResult.new(@attacks, hits, wounds, unsaved_wounds)
  end

  def roll_armor_save(caused_wounds)
    save_modifier = @attack_stats.strength > 3 ? @attack_stats.strength - 3 : 0
    roll_needed = @defend_stats.armor_save + save_modifier

    caused_wounds - count_values_higher_than(roll_dice(caused_wounds),
                                             roll_needed)
  end

  def roll_extra_save(caused_wounds)
    caused_wounds - count_values_higher_than(roll_dice(caused_wounds),
                                             @defend_stats.ward_save)
  end

  def roll_hits
    rolls = ComputeHits.compute(@attacks, to_hit_number,
                                @attacker.hit_reroll_values(to_hit_number))
    @attacker.equipment.each do |item|
      rolls = item.roll_hits(@round_number, rolls)
    end
    count_values_higher_than(rolls, to_hit_number)
  end

  def roll_saves(caused_wounds)
    roll_extra_save(roll_armor_save(caused_wounds))
  end

  def roll_wounds(hits)
    rolls =
      ComputeWounds.compute(hits, to_wound_number,
                            @attacker.wound_reroll_values(to_wound_number))
    @attacker.equipment.each do |item|
      rolls = item.roll_wounds(@round_number, rolls)
    end
    count_values_higher_than(rolls, to_wound_number)
  end

  def to_hit_number
    roll_needed = ComputeHitNeeded.hit_needed(@attack_stats.weapon_skill,
                                              @defend_stats.weapon_skill)
    @attacker.equipment.each do |item|
      roll_needed = item.hit_needed(@round_number, roll_needed)
    end
    roll_needed
  end

  def to_wound_number
    roll_needed = ComputeWoundNeeded.wound_needed(@attack_stats.strength,
                                                  @defend_stats.toughness)
    @attacker.equipment.each do |item|
      roll_needed = item.wound_needed(@round_number, roll_needed)
    end
    roll_needed
  end

  def ==(other)
    round_number == other.round_number &&
      attacker == other.attacker &&
      attacks  == other.attacks &&
      defender == other.defender
  end
end

