# This class is responsible for finding the available targets the given attacker
# can target in the opposing unit.
class TargetFinder
  def self.find(attacker, defender)
    intervals = attacker.selected_intervals
    defender.targets_in_intervals(intervals)
  end
end

