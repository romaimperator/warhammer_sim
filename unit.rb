# This class is the base class for all units in the system. It
# defines the interface that needs to be satisfied in order for
# a unit to be used as a root unit in a simulation.
class Unit
  # Is the unit dead?
  #
  # returns - boolean
  def dead?
    fail NotYetImplemented
  end

  # Tells the unit to cause it self to be dead.
  def destroy
    fail NotYetImplemented
  end

  def width
    fail NotYetImplemented
  end

  # Get the width of the entire unit in millimeters.
  #
  # returns - the width in millimeters
  def mm_width
    fail NotYetImplemented
  end

  def length
    fail NotYetImplemented
  end

  # Get the length of the entire unit in millimeters.
  #
  # returns - the length in millimeters
  def mm_length
    fail NotYetImplemented
  end

  # This function takes an array of intervals and returns targets and the number
  # of intervals which can target those targets.
  #
  # intervals - an array of intervals which are each an array with the lower
  #             value first
  #
  # returns - a hash with keys that are arrays of targets and values that are
  #           the number of intervals which have that array of targets to pick
  #           from
  def targets_in_intervals(_intervals)
    fail NotYetImplemented
  end

  # Causes the unit to take wounds based on what kind of unit it is.
  #
  # number_of_wounds - the number of wounds this unit should take
  #
  # returns - nothing
  def take_wounds(_number_of_wounds)
    fail NotYetImplemented
  end

  # Gets the initiative values in this unit.
  #
  # round_number - the current round number
  #
  # returns - an array of the initiatives this unit has attackers at so we can
  #           skip initiatve numbers that aren't needed
  def initiative_steps(_round_number)
    fail NotYetImplemented
  end

  # Creates matchups for a given initiative value.
  #
  # initiative_value - the given initiative to create matchups for
  # round_number - the current round number
  # target_unit - the unit to pick targets from
  #
  # returns - an array of AttackMatchups
  def matchups_for_initiative(_initiative_value, _round_number, _target_unit)
    fail NotYetImplemented
  end
end

