class Equipment
  def attacks(round_number, current_attacks, unit)
    current_attacks
  end

  def stats(round_number, current_stats)
    current_stats
  end

  def hit_needed(round_number, roll_needed)
    roll_needed
  end

  def wound_needed(round_number, roll_needed)
    roll_needed
  end

  def hit_reroll_values(round_number, hit_needed)
    []
  end

  def wound_reroll_values(round_number, wound_needed)
    []
  end

  def roll_hits(round_number, rolls)
    rolls
  end

  def roll_wounds(round_number, rolls)
    rolls
  end
end

