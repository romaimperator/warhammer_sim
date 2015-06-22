require "die_roller"

class ComputeRolls
  def initialize(auditor)
    @auditor = auditor
  end

  def compute
    DieRoller.count_values_higher_than(rolls, value_needed)
  end

  def rolls
    @auditor.rolls(DieRoller.roll_dice_and_reroll(number, value_needed, reroll))
  end

  def number
    fail NotYetImplemented
  end

  def value_needed
    @value_needed ||= @auditor.value_needed(raw_value_needed)
  end

  def raw_value_needed
    fail NotYetImplemented
  end

  def reroll
    @auditor.reroll_values([], value_needed)
  end
end

