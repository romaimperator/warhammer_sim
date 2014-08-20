class RerollMisses < Equipment
  def hit_reroll_values(round_number, hit_needed)
    (1...hit_needed).to_a
  end
end

