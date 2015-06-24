require "compute_rolls"
require "auditor"

class ComputeHits < ComputeRolls
  attr_reader :number

  def initialize(attack, defender_weapon_skill, auditor=PassThroughAuditor.new)
    super(auditor)
    @attack                = attack
    @number                = attack.number
    @defender_weapon_skill = defender_weapon_skill
  end

  def raw_value_needed
    if @attack.weapon_skill - @defender_weapon_skill > 0
      3
    elsif @defender_weapon_skill > (2 * @attack.weapon_skill)
      5
    else
      4
    end
  end
end

