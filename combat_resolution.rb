require "constants"
require "die_roller"

CombatResolution = Struct.new(:attacker, :defender, :attacker_result,
                              :defender_result) do
  INSANE_COURAGE_ROLL = 2

  def compute
    return :tie if resolution_difference == 0
    winner, loser, win_constant, flee_constant, hold_constant = find_combat_winner
    if roll_break_test(loser, resolution_difference, winner)
      if roll_pursuit >= roll_flee
        loser.take_wounds(loser.model_count)
        win_constant
      else
        flee_constant
      end
    else
      hold_constant
    end
  end

  def find_combat_winner
    if resolution_difference > 0
      [attacker, defender, :attacker_win, :defender_flee, :defender_hold]
    else
      [defender, attacker, :defender_win, :attacker_flee, :attacker_hold]
    end
  end

  def resolution_difference
    @resolution_difference ||=
      combat_resolution_earned(attacker, attacker_result) -
      combat_resolution_earned(defender, defender_result)
  end

  def combat_resolution_earned(unit, result)
    result.unsaved_wounds
  end

  def roll_break_test(unit, modifier, defender)
    result = sum_roll(2)
    if is_steadfast?(unit, defender)
      check_break_test(unit, result, 0)
    else
      check_break_test(unit, result, modifier)
    end
  end

  def is_steadfast?(unit, other_unit)
    unit.number_of_ranks > other_unit.number_of_ranks
  end

  def check_break_test(unit, roll, modifier)
    roll == INSANE_COURAGE_ROLL || !check_leadership_test(unit, roll, modifier)
  end

  def check_leadership_test(unit, roll, modifier)
    roll <= unit.leadership + modifier
  end

  def roll_pursuit
    sum_roll(2)
  end

  def roll_flee
    sum_roll(2)
  end
end

