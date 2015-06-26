require "factory"
require "rank_and_file_model"

def RankAndFileModelFactory(name: "halberd", mm_width: 20, mm_length: 20, equipment: [],
                            stats: Stats.new(3, 3, 3, 1, 3, 1, 7, 6, 7))
  RankAndFileModel.new(name, mm_width, mm_length, equipment, stats)
end
