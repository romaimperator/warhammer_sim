require "compute_rolls"
require "auditor"

class ComputeArmorSave < ComputeRolls
  attr_reader :number

  def initialize(wounds, attack_strength, defender_armor_save, auditor=PassThroughAuditor.new)
    super(auditor)
    @number              = wounds
    @attack_strength     = attack_strength
    @defender_armor_save = defender_armor_save
  end

  def raw_value_needed
    save_modifier = @attack_strength > 3 ? @attack_strength - 3 : 0
    @defender_armor_save + save_modifier
  end
end

