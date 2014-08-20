class RerollWounds < Equipment
  def wound_reroll_values(round_number, wound_needed)
    (1...wound_needed).to_a
  end
end

