class ComputeWoundNeeded
  def self.wound_needed(attacker_strength, defender_toughness)
    roll_needed = defender_toughness - attacker_strength + 4
    roll_needed = 6 if roll_needed > 6
    roll_needed = 2 if roll_needed < 2
    roll_needed
  end
end

