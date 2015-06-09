require File.expand_path(File.dirname(__FILE__) + "../../../model")
require "factories/part_factory"

# Creates instances of Models with default values for testing
class ModelFactory
  attr_accessor :name
  attr_accessor :parts
  attr_accessor :mm_width
  attr_accessor :mm_length
  attr_accessor :equipment

  def initialize
    @name = "halberd"
    @parts = [PartFactory.new.build]
    @mm_width = 20
    @mm_length = 20
    @equipment = []
  end

  def build
    Model.new(@name, @parts, @mm_width, @mm_length, @equipment)
  end

  def name(name)
    @name = name
    self
  end

  def parts(parts)
    @parts = parts
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

