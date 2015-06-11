require_relative "compute_hit_needed"
require_relative "compute_wound_needed"

Unit = Struct.new(:contained_units) do
  def dead?
    contained_units.reduce(true) do |previous_values, unit|
      previous_values && unit.dead?
    end
  end

  def destroy
    fail NotYetImplemented
  end
  
  def model_count
    contained_units.reduce(0) { |a, e| a + e.model_count }
  end

  def width
    fail NotYetImplemented
  end

  def mm_width
    fail NotYetImplemented
  end

  def length
    fail NotYetImplemented
  end

  def leadership
    contained_units.max_by { |unit| unit.leadership }.leadership
  end

  def mm_length
    fail NotYetImplemented
  end

  def selected_intervals
    fail NotYetImplemented
  end

  def targets_in_intervals(_intervals)
    fail NotYetImplemented
  end

  def take_wounds(_number_of_wounds)
    fail NotYetImplemented
  end

  def initiative_steps(round_number)
    contained_units.reduce([]) do |steps, unit|
      steps | unit.initiative_steps(round_number)
    end
  end

  def units_with_initiative(initiative_value, round_number)
    contained_units.each do |unit|
      if unit.initiative(round_number) == initiative_value
        yield unit
      end
    end
  end
end

