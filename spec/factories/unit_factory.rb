require File.expand_path(File.dirname(__FILE__) + "../../../unit")
require "factories/model_factory"

# Creates Unit instances with default values for testing
class UnitFactory
  attr_accessor :model,
                :special_models,
                :size,
                :width,
                :offset,
                :equipment

  def initialize
    @model = ModelFactory.new.build
    @special_models = []
    @size = 10
    @width = 5
    @offset = 0
    @equipment = []
  end

  def build
    Unit.new(@model, @special_models, @size, @width, @offset, @equipment)
  end

  def model(model)
    @model = model
    self
  end

  def special_models(special_models)
    @special_models = special_models
    self
  end

  def size(size)
    @size = size
    self
  end

  def width(width)
    @width = width
    self
  end

  def offset(offset)
    @offset = offset
    self
  end

  def equipment(equipment)
    @equipment = equipment
    self
  end
end

