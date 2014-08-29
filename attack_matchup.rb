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

  def attacker_stats
    total_stats = @attacker.model.dup
    @attacker.for_each_item do |item|
      total_stats = item.stats(@round_number, total_stats)
    end
    total_stats
  end

  def compute_wounds
    hits = roll_hits
    wounds = roll_wounds(hits)
    unsaved_wounds = roll_saves(wounds)
    @attacker.hits = hits
    @attacker.wounds_caused = wounds
    @attacker.unsaved_wounds = unsaved_wounds
  end

  def defender_stats
    total_stats = @defender.model.dup
    @defender.for_each_item do |item|
      total_stats = item.stats(@round_number, total_stats)
    end
    total_stats
  end

  def hit_reroll_values
    values = []
    @attacker.for_each_item do |item|
      values += item.hit_reroll_values(@round_number, to_hit_number)
    end
    values.uniq
  end

  def number_of_attacks
    total_attacks = @attacker.base_attacks(@defender)
    @attacker.for_each_item do |item|
      total_attacks = item.attacks(@round_number, total_attacks, @attacker)
    end
    total_attacks
  end

  def roll_armor_save(caused_wounds)
    save_modifier = attacker_stats.strength > 3 ? attacker_stats.strength - 3 : 0
    roll_needed = defender_stats.armor_save + save_modifier

    caused_wounds - count_values_higher_than(roll_dice(caused_wounds), roll_needed)
  end

  def roll_extra_save(caused_wounds)
    caused_wounds - count_values_higher_than(roll_dice(caused_wounds), defender_stats.ward_save)
  end

  def roll_hits
    rolls = ComputeHits.compute(number_of_attacks, to_hit_number, hit_reroll_values)
    @attacker.for_each_item do |item|
      rolls = item.roll_hits(@round_number, rolls)
    end
    count_values_higher_than(rolls, to_hit_number)
  end

  def roll_saves(caused_wounds)
    roll_extra_save(roll_armor_save(caused_wounds))
  end

  def roll_wounds(hits)
    rolls = ComputeWounds.compute(hits, to_wound_number, wound_reroll_values)
    @attacker.for_each_item do |item|
      rolls = item.roll_wounds(@round_number, rolls)
    end
    count_values_higher_than(rolls, to_wound_number)
  end

  def to_hit_number
    roll_needed = ComputeHitNeeded.hit_needed(attacker_stats.weapon_skill, defender_stats.weapon_skill)
    @attacker.for_each_item do |item|
      roll_needed = item.hit_needed(@round_number, roll_needed)
    end
    roll_needed
  end

  def to_wound_number
    roll_needed = ComputeWoundNeeded.wound_needed(attacker_stats.strength, defender_stats.toughness)
    @attacker.for_each_item do |item|
      roll_needed = item.wound_needed(@round_number, roll_needed)
    end
    roll_needed
  end

  def wound_reroll_values
    values = []
    @attacker.for_each_item do |item|
      values += item.wound_reroll_values(@round_number, to_wound_number)
    end
    values.uniq
  end
end

