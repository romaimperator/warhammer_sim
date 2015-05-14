require_relative '../../rank_and_file_unit'
require_relative 'model_factory'

class RankAndFileUnitFactory
  def initialize
    @files = 5
    @container_unit = ModelFactory.new.build
    @container_unit_count = 10
    @other_units = {}
  end

  def build
    RankAndFileUnit.new(@files, @container_unit, @container_unit_count, @other_units)
  end

  def files(files)
    @files = files
    self
  end

  def container_unit(container_unit)
    @container_unit = container_unit
    self
  end

  def container_unit_count(container_unit_count)
    @container_unit_count = container_unit_count
    self
  end

  def other_units(other_units)
    @other_units = other_units
    self
  end
end

