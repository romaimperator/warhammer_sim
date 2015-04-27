class Model < Struct.new(:name, :parts, :mm_width, :mm_length, :equipment)
  attr_accessor :unit

  def hits
    parts.reduce(0) { |sum, part| sum + part.hits }
  end

  def unsaved_wounds
    parts.reduce(0) { |sum, part| sum + part.unsaved_wounds }
  end

  def wounds_caused
    parts.reduce(0) { |sum, part| sum + part.wounds_caused }
  end

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
    if has_part?(part_that_died)
      remove_part(part_that_died)

      if !has_any_parts?
        unit.notify_model_died(self)
      end
    else
      raise Exception.new("Part #{part_that_died} not part of this model #{self}: #{parts}")
    end
  end

  def take_wounds(wounds_caused)
    if self == unit.model
      unit.take_wounds(wounds_caused)
    else
      parts[0].take_wounds(wounds_caused)
    end
  end

  private

  def has_part?(part)
    parts.include?(part)
  end

  def has_any_parts?
    parts.size == 0
  end

  def remove_part(part_to_remove)
    self.parts -= [part_to_remove]
  end
end

