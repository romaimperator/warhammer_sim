#!/usr/bin/env ruby -Ispec

#require_relative "spec/factories/rank_and_file_unit_factory"
require_relative "spec/factories/model_factory"
require "benchmark/ips"

#other_units = {
#  [1, 1] => ModelFactory.new.name("champ").mm_width(20).build
#}
#unit = RankAndFileUnitFactory.new.files(5).other_units(other_units)
#  .build_positions
#intervals = [[0, 20], [20, 40], [40, 60], [60, 80], [80, 100]]

Benchmark.ips do |x|
  x.report("with a string") { str == str2 }
  x.report("with a symbol") { sym == sym2 }
end

#6000.times do
#  unit.targets_in_intervals(intervals)
#end
