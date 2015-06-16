require "unit"

# This class represents a single model in the simulation. It tracks equipment,
# the size, etc.
class Model < Unit
  include Comparable
  attr_accessor :parent_unit
  attr_accessor :name
  attr_accessor :mm_width
  attr_accessor :mm_length
  attr_accessor :equipment

  def initialize(name, mm_width, mm_length, equipment)
    @name      = name
    @mm_width  = mm_width
    @mm_length = mm_length
    @equipment = equipment
    @equipment.each { |item| item.owner = self }
  end

  def to_s
    name
  end

  def inspect
    name
  end

  def attack_stats(round_number)
    fail NotYetImplemented
  end

  def defend_stats(round_number)
    fail NotYetImplemented
  end
  
  def hash
    @hash ||= name.hash
  end

  def ==(other)
    return false unless other.kind_of?(Model)
    name == other.name
  end

  def <=>(other)
    name <=> other.name
  end

  def call_equipment(action_to_call, round_number, starting_value, *args)
    @equipment.reduce(starting_value) { |a, item| item.send(action_to_call, round_number, a, *args) }
  end

  def call_equipment_hook(hook_to_call, round_number, *args)
    @equipment.each { |item| item.send(hook_to_call, round_number, *args) }
  end

  def remove_equipment(item)
    @equipment -= [item]
  end
end

