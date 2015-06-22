require "compute_rolls"
require "auditor"

class ComputeWardSave < ComputeRolls
  attr_reader :number

  def initialize(wounds, defender_ward_save, auditor=PassThroughAuditor.new)
    super(auditor)
    @number             = wounds
    @defender_ward_save = defender_ward_save
  end

  def raw_value_needed
    @defender_ward_save
  end
end

