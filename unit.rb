require_relative 'compute_hit_needed'
require_relative 'compute_wound_needed'

Unit = Struct.new(:contained_units) do
  def dead?
    contained_units.reduce(true) do |previous_values, unit|
      previous_values && unit.dead?
    end
  end

  def model_count
    contained_units.reduce(0) { |sum, unit| sum + unit.model_count }
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

  def mm_length
    fail NotYetImplemented
  end

end

