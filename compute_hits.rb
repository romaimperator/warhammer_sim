require "die_roller"

class ComputeHits
  def initialize(attack, defender_weapon_skill, hit_auditor)
    @attack                = attack
    @defender_weapon_skill = defender_weapon_skill
    @hit_auditor           = hit_auditor
  end

  def compute
    DieRoller.count_values_higher_than(rolls, hit_needed)
  end

  def hit_needed
    @hit_needed ||= @hit_auditor.hit_needed(raw_hit_needed)
  end

  def raw_hit_needed
    if @attack.weapon_skill - @defender_weapon_skill > 0
      3
    elsif @defender_weapon_skill > (2 * @attack.weapon_skill)
      5
    else
      4
    end
  end

  def rolls
    @hit_auditor.roll_hits(
      DieRoller.roll_dice_and_reroll(@attack.number, hit_needed, reroll)
    )
  end

  def reroll
    @hit_auditor.hit_reroll_values([], hit_needed)
  end
end

