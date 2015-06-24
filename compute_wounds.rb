require "compute_rolls"
require "auditor"

class ComputeWounds < ComputeRolls
  attr_reader :number

  def initialize(hits, attack_strength, defender_toughness, auditor=PassThroughAuditor.new)
    super(auditor)
    @number             = hits
    @attack_strength    = attack_strength
    @defender_toughness = defender_toughness
  end

  def raw_value_needed
    roll_needed = @defender_toughness - @attack_strength + 4
    [[roll_needed, 2].max, 6].min
  end
end

