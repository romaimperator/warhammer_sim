require_relative 'equipment'

class Halberd < Equipment
  def strength(round_number, current_strength)
    current_strength + 1
  end
end

