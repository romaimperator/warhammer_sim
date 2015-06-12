require "equipment/equipment"

class Standard < Equipment
  def ==(other)
    other.is_a?(Standard)
  end
end

