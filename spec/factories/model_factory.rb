require "model"

# Creates instances of Models with default values for testing
class ModelFactory
  attr_accessor :name
  attr_accessor :mm_width
  attr_accessor :mm_length
  attr_accessor :equipment

  def initialize
    @name = "halberd"
    @mm_width = 20
    @mm_length = 20
    @equipment = []
  end

  def build
    Model.new(@name, @mm_width, @mm_length, @equipment)
  end

  def name(name)
    @name = name
    self
  end

  def mm_width(mm_width)
    @mm_width = mm_width
    self
  end

  def mm_length(mm_length)
    @mm_length = mm_length
    self
  end

  def equipment(equipment)
    @equipment = equipment
    self
  end
end

