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
    @attacker.hits = hits
    @attacker.wounds_caused = wounds
    @attacker.unsaved_wounds = unsaved_wounds
  end

  def roll_armor_save(caused_wounds)
    save_modifier = @attacker.strength(@round_number) > 3 ? @attacker.strength(@round_number) - 3 : 0
    roll_needed = @defender.stats(@round_number).armor_save + save_modifier

    caused_wounds - count_values_higher_than(roll_dice(caused_wounds), roll_needed)
  end

  def roll_extra_save(caused_wounds)
    caused_wounds - count_values_higher_than(roll_dice(caused_wounds), @defender.stats(@round_number).ward_save)
  end

  def roll_hits
    rolls = ComputeHits.compute(@attacker.number_of_attacks(@round_number, @defender), to_hit_number, @attacker.hit_reroll_values(@round_number, to_hit_number))
    @attacker.for_each_item do |item|
      rolls = item.roll_hits(@round_number, rolls)
    end
    count_values_higher_than(rolls, to_hit_number)
  end

  def roll_saves(caused_wounds)
    roll_extra_save(roll_armor_save(caused_wounds))
  end

  def roll_wounds(hits)
    rolls = ComputeWounds.compute(hits, to_wound_number, @attacker.wound_reroll_values(@round_number, to_wound_number))
    @attacker.for_each_item do |item|
      rolls = item.roll_wounds(@round_number, rolls)
    end
    count_values_higher_than(rolls, to_wound_number)
  end

  def to_hit_number
    roll_needed = ComputeHitNeeded.hit_needed(@attacker.stats(@round_number).weapon_skill, @defender.stats(@round_number).weapon_skill)
    @attacker.for_each_item do |item|
      roll_needed = item.hit_needed(@round_number, roll_needed)
    end
    roll_needed
  end

  def to_wound_number
    roll_needed = ComputeWoundNeeded.wound_needed(@attacker.strength(@round_number), @defender.stats(@round_number).toughness)
    @attacker.for_each_item do |item|
      roll_needed = item.wound_needed(@round_number, roll_needed)
    end
    roll_needed
  end
end

