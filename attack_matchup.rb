require_relative 'attack_matchup_result'

class AttackMatchup
  attr_reader :attacker
  attr_reader :defender

  def initialize(round_number, attacker, defender)
    @round_number = round_number
    @attacker = attacker
    @defender = defender
  end

  def attack
    compute_wounds
  end

  def compute_wounds
    hits = roll_hits
    wounds = roll_wounds(hits)
    unsaved_wounds = roll_saves(wounds)
    AttackMatchupResult.new(@attacker.attacks, hits, wounds, unsaved_wounds)
  end

  def roll_armor_save(caused_wounds)
    save_modifier = @attacker.strength > 3 ? @attacker.strength - 3 : 0
    roll_needed = @defender.armor_save + save_modifier

    caused_wounds - count_values_higher_than(roll_dice(caused_wounds), roll_needed)
  end

  def roll_extra_save(caused_wounds)
    caused_wounds - count_values_higher_than(roll_dice(caused_wounds), @defender.ward_save)
  end

  def roll_hits
    rolls = ComputeHits.compute(@attacker.attacks, to_hit_number, @attacker.hit_reroll_values(to_hit_number))
    @attacker.equipment.each do |item|
      rolls = item.roll_hits(@round_number, rolls)
    end
    count_values_higher_than(rolls, to_hit_number)
  end

  def roll_saves(caused_wounds)
    roll_extra_save(roll_armor_save(caused_wounds))
  end

  def roll_wounds(hits)
    rolls = ComputeWounds.compute(hits, to_wound_number, @attacker.wound_reroll_values(to_wound_number))
    @attacker.equipment.each do |item|
      rolls = item.roll_wounds(@round_number, rolls)
    end
    count_values_higher_than(rolls, to_wound_number)
  end

  def to_hit_number
    roll_needed = ComputeHitNeeded.hit_needed(@attacker.weapon_skill, @defender.weapon_skill)
    @attacker.equipment.each do |item|
      roll_needed = item.hit_needed(@round_number, roll_needed)
    end
    roll_needed
  end

  def to_wound_number
    roll_needed = ComputeWoundNeeded.wound_needed(@attacker.strength, @defender.toughness)
    @attacker.equipment.each do |item|
      roll_needed = item.wound_needed(@round_number, roll_needed)
    end
    roll_needed
  end
end

