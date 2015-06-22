require "unit"

# This class defines the required information for a unit that can contain other units.
# It acts as the base class for RankAndFileUnits.
class ContainerUnit < Unit
  attr_accessor :contained_units

  def initialize(contained_units)
    @contained_units = contained_units
    contained_units.each { |unit| unit.parent_unit = self }
  end

  def dead?
    contained_units.reduce(true) do |previous_values, unit|
      previous_values && unit.dead?
    end
  end

  def model_count
    contained_units.reduce(0) { |a, e| a + e.model_count }
  end

  def leadership
    contained_units.max_by { |unit| unit.leadership }.leadership
  end

  def initiative_steps(round_number)
    contained_units.reduce([]) do |steps, unit|
      steps | unit.initiative_steps(round_number)
    end
  end
end
