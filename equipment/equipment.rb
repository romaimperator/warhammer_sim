class Equipment
  # Given the current round number and the current stat line, this method returns a modified
  # stat line.
  # Example usage: adding +2 strength on the first round of combat
  def stats(round_number, current_stats)
    current_stats
  end

  # Given the current round number and the to hit roll (value of 4 means 4+ to hit), this
  # method returns a modified to hit roll.
  # Example usage: adding +1 to hit
  def hit_needed(round_number, roll_needed)
    roll_needed
  end

  # Given the current round number and the to wound roll (value of 4 means 4+ to wound), this
  # method returns a modified to wound roll.
  # Example usage: adding +1 to wound
  def wound_needed(round_number, roll_needed)
    roll_needed
  end

  # Given the current round number and the to hit roll (value of 4 means 4+ to hit), this
  # method returns an array of numbers to reroll if any dice equal a number in the array.
  # Example usage: reroll misses by returning [1...hit_needed] (... is non-inclusive end so
  #     result is [1, 2, 3] if hit_needed is 4.
  def hit_reroll_values(round_number, reroll_values, hit_needed)
    reroll_values
  end

  # Given the current round number and the to wound roll (value of 4 means 4+ to wound), this
  # method returns an array of numbers to reroll if any dice equal a number in the array.
  # Example usage: reroll failed wounds by returning [1...hit_needed] (... is non-inclusive
  #     end so result is [1, 2, 3] if wound_needed is 4.
  def wound_reroll_values(round_number, reroll_values, wound_needed)
    reroll_values
  end

  # Given the current round number and the results of the hit dice rolls, this method returns
  # an array of dice results of hitting.
  # Example usage: implement poison hits by finding 6s (see equipment/poison_attacks.rb for more)
  def roll_hits(round_number, rolls)
    rolls
  end

  # Given the current round number and the results of the wound dice rolls, this method returns
  # an array of dice results of wounding.
  # Example usage: implement killing blow hits by finding 6s
  def roll_wounds(round_number, rolls)
    rolls
  end

  def weapon_skill(round_number, current_weapon_skill)
    current_weapon_skill
  end

  # Given the current round number, the strength of the unit, and the unit itself,
  # this method returns a modified strength.
  # Example usage: adding +1 strength in the first round of combat for a mounted spearman.
  def strength(round_number, current_strength)
    current_strength
  end

  def toughness(round_number, current_toughness)
    current_toughness
  end

  def wounds(round_number, current_wounds)
    current_wounds
  end

  def initiative(round_number, current_initiative, defender)
    current_initiative
  end

  # Given the current round number, the number of attacks the unit has, and the unit itself,
  # this method returns a modified number of attacks.
  # Example usage: adding an extra rank of attacks for foot spearmen.
  def attacks(round_number, current_attacks, unit)
    current_attacks
  end

  def leadership(round_number, current_leadership)
    current_leadership
  end

  def armor_save(round_number, current_armor_save)
    current_armor_save
  end

  def ward_save(round_number, current_ward_save)
    current_ward_save
  end

end

