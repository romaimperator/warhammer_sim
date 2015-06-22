require "die_roller"

class ComputeWounds
  def initialize(hits, attack_strength, defender_toughness, wound_auditor)
    @hits               = hits
    @attack_strength    = attack_strength
    @defender_toughness = defender_toughness
    @wound_auditor      = wound_auditor
  end

  def compute
    DieRoller.count_values_higher_than(rolls, wound_needed)
  end

  def wound_needed
    @wound_needed ||= @wound_auditor.wound_needed(raw_wound_needed)
  end

  def raw_wound_needed
    roll_needed = @defender_toughness - @attack_strength + 4
    [[roll_needed, 2].max, 6].min
  end

  def rolls
    @wound_auditor.roll_wounds(
      DieRoller.roll_dice_and_reroll(@hits, wound_needed, reroll)
    )
  end

  def reroll
    @wound_auditor.wound_reroll_values([], wound_needed)
  end
end

