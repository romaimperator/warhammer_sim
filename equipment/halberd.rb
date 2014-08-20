require_relative 'equipment'

class Halberd < Equipment
  def stats(round_number, current_stats)
    current_stats.strength += 1
    current_stats
  end
end

