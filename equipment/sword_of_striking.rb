class SwordOfStriking < Equipment
  def hit_needed(round_number, roll_needed)
    roll_needed - 1 # +1 to hit
  end
end

