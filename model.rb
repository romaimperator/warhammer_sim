# This class represents a single model in the simulation. It tracks equipment,
# the size, etc.
Model = Struct.new(:name, :parts, :mm_width, :mm_length, :equipment) do
  include Comparable
  attr_accessor :unit

  def initialize(*args, &block)
    super
    parts.each do |part|
      part.model = self
      part.add_equipment(equipment)
    end
  end

  def add_equipment(equipment)
    self.equipment += equipment
    parts.each { |part| part.add_equipment(equipment) }
  end

  def method_missing(name, *args)
    parts[0].send(name, *args)
  end

  def dead?
    wounds <= 0
  end

  def strike_first?
    false
  end

  def to_s
    name
  end

  def inspect
    name
  end

  def draw
    base_width_in_units = mm_width / 5
    base_length_in_units = mm_length / 5
    (0..(base_length_in_units - 1)).map do |row|
      if row == 0 || row == base_length_in_units - 1
        " " + "--" * (base_width_in_units - 2) + " "
      else
        "|" + "  " * (base_width_in_units - 2) + "|"
      end
    end
  end

  def notify_part_died(part_that_died)
    if includes_part?(part_that_died)
      remove_part(part_that_died)

      unit.notify_model_died(self) unless has_any_parts?
    else
      fail Exception,
           "Part #{part_that_died} not part of this model #{self}: #{parts}"
    end
  end

  def take_wounds(wounds_caused)
    if self == unit.model
      unit.take_wounds(wounds_caused)
    else
      parts[0].take_wounds(wounds_caused)
    end
  end

  def hash
    name.hash
  end

  def ==(other)
    return false unless other.is_a?(Model)
    name == other.name
  end

  def <=>(other)
    name <=> other.name
  end

  def initiative_steps(round_number)
    parts.map { |part| part.initiative(round_number) }.uniq
  end

  private

  def includes_part?(part)
    parts.include?(part)
  end

  def has_any_parts?
    parts.size == 0
  end

  def remove_part(part_to_remove)
    self.parts -= [part_to_remove]
  end
end

