class AttackMatchup
  def initialize(round_number, attacker, defender)
    @round_number = round_number
    @attacker = attacker
    @defender = defender
  end

  def number_of_attacks
    @attacker.attacks(@number)
  end

  def to_hit_number
    @attacker.hit_needed(@number, @defender)
  end

  def to_wound_number
    @attacker.wound_needed(@number, @defender)
  end

  def hit_reroll_values
    @attacker.hit_reroll_values(@number, to_hit_number)
  end

  def wound_reroll_values
    @attacker.wound_reroll_values(@number, to_wound_number)
  end

  def compute_wounds
    hits = ComputeHits.compute(number_of_attacks, to_hit_number, hit_reroll_values)
    wounds = ComputeWounds.compute(hits, to_wound_number, wound_reroll_values)
    unsaved_wounds = @defender.roll_saves(wounds, @attacker.strength)
    @attacker.wounds_caused = unsaved_wounds
  end

  def attack
    compute_wounds
  end

  def attack_simutaneous
  end
end

