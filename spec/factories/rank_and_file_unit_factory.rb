require "rank_and_file_unit"
require "factories/rank_and_file_model_factory"

# Creates instances of RankAndFileUnits with default values for testing
class RankAndFileUnitFactory
  def initialize
    @files                = 5
    @container_unit       = RankAndFileModelFactory.new.build
    @container_unit_count = 10
    @other_units          = {}
    @offset               = 0
    @equipment            = []
  end

  def build
    RankAndFileUnit.new(@files, @container_unit, @container_unit_count,
                        @other_units, @offset, @equipment)
  end

  def build_positions
    RankAndFileUnit.new_with_positions(@files, @container_unit,
                                       @container_unit_count,
                                       @other_units, @offset, @equipment)
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

  def offset(offset)
    @offset = offset
    self
  end

  def equipment(equipment)
    @equipment = equipment
    self
  end
end

