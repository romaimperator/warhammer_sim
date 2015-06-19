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
  attr_reader :attack
  attr_reader :defender

  def initialize(round_number, attack, defender)
    @round_number = round_number
    @attack       = attack
    @defender     = defender
    @defend_stats = defender.defend_stats(round_number)
  end

  def attack
    compute_wounds
  end

  def compute_wounds
    hits = 0
    wounds = 0
    if @attack.weapon_skill != :auto_hit
      hits = roll_hits
      wounds = roll_wounds(hits)
    else
      wounds = roll_wounds(@attack.number)
    end
    unsaved_wounds = roll_saves(wounds)
    AttackMatchupResult.new(@attack.number, hits, wounds, unsaved_wounds)
  end

  def roll_armor_save(caused_wounds)
    save_modifier = @attack.strength > 3 ? @attack.strength - 3 : 0
    roll_needed = @defend_stats.armor_save + save_modifier

    caused_wounds - count_values_higher_than(roll_dice(caused_wounds),
                                             roll_needed)
  end

  def roll_extra_save(caused_wounds)
    caused_wounds - count_values_higher_than(roll_dice(caused_wounds),
                                             @defend_stats.ward_save)
  end

  def roll_hits
    rolls = roll_dice_and_reroll(@attack.number, to_hit_number,
                                 hit_reroll_values(to_hit_number))
    modified_rolls = call_attack_equipment(:roll_hits, rolls)
    count_values_higher_than(modified_rolls, to_hit_number)
  end

  def roll_saves(caused_wounds)
    roll_extra_save(roll_armor_save(caused_wounds))
  end

  def roll_wounds(hits)
    rolls = roll_dice_and_reroll(hits, to_wound_number,
                                 wound_reroll_values(to_wound_number))
    modified_rolls = call_attack_equipment(:roll_wounds, rolls)
    count_values_higher_than(modified_rolls, to_wound_number)
  end

  def to_hit_number
    roll_needed = ComputeHitNeeded.hit_needed(@attack.weapon_skill,
                                              @defend_stats.weapon_skill)
    call_attack_equipment(:hit_needed, roll_needed)
  end

  def to_wound_number
    roll_needed = ComputeWoundNeeded.wound_needed(@attack.strength,
                                                  @defend_stats.toughness)
    call_attack_equipment(:wound_needed, roll_needed)
  end

  def wound_reroll_values(to_wound_number)
    call_attack_equipment(:wound_reroll_values, [], to_wound_number).uniq
  end

  def hit_reroll_values(to_hit_number)
    call_attack_equipment(:hit_reroll_values, [], to_hit_number).uniq
  end

  def ==(other)
    round_number == other.round_number &&
      attack  == other.attack
  end

  private

  def call_attack_equipment(action_to_call, starting_value, *args)
    @attack.equipment.reduce(starting_value) do |result, item|
      item.send(action_to_call, @round_number, result, *args)
    end
  end
end

