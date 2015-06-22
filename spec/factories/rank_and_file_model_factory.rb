require "factory"
require "rank_and_file_model"
require "factories/lone_model_factory"

class RankAndFileModelFactory
  include Factory

  factter name: "halberd",
    mm_width: 20,
    mm_length: 20,
    equipment: [],
    stats: Stats.new(3, 3, 3, 1, 3, 1, 7, 6, 7)

  def build
    RankAndFileModel.new(@name, @mm_width, @mm_length, @equipment, @stats)
  end
end

