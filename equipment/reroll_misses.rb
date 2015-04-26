class RerollMisses < Equipment
  def hit_reroll_values(round_number, reroll_values, hit_needed)
    reroll_values + (1...hit_needed).to_a
  end
end

