require "factory"
require "lone_model"

def LoneModelFactory(name: "halberd", mm_width: 20, mm_length: 20, equipment: [],
                     stats: Stats.new(3, 3, 3, 1, 3, 1, 7, 6, 7))
  LoneModel.new(name, mm_width, mm_length, equipment, stats)
end
