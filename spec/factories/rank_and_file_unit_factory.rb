require "rank_and_file_unit"
require "factories/rank_and_file_model_factory"

# Creates instances of RankAndFileUnits with default values for testing
def RankAndFileUnitFactory(files: 5, container_unit: RankAndFileModelFactory(),
                           container_unit_count: 10, other_units: {}, offset: 0,
                           equipment: [])
  RankAndFileUnit.new_with_positions(files, container_unit, container_unit_count,
                                     other_units, offset, equipment)
end
