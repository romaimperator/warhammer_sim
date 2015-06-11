#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path("..", __FILE__))

require "die_roller"
require "constants"
require "trial"
require "round"
require "part"
require "model"
require "unit"
require "standard_unit"
require "rank_and_file_unit"
require "simulation"
require "equipment/halberd"
require "equipment/spear"
require "equipment/sword_of_striking"
require "equipment/reroll_misses"
require "equipment/reroll_wounds"
require "equipment/murderous_prowess"
require "equipment/poison_attacks"
require "equipment/extra_hand_weapon"

# ready "testing" do
#  before do
#    @r = RankAndFileUnit.new_with_positions(5, Model.new("halberd", [
#                Part.new("man", 3, 3, 3, 1, 3, 2, 7, 6, 7, []),
#    ], 20, 20, []), 40, [1, 3] => Model.new("champion", [
#                Part.new("man", 3, 3, 3, 1, 3, 2, 7, 6, 7, []),
#              ], 40, 40, []))
#  end
#
#  go "test" do
#    39.times do
#      @r.take_wounds(1)
#    end
#  end
# end

NUMBER_OF_TRIALS = 100

class TrialRunner
  def initialize(&block)
    @block = block
  end

  def simulate
    Trial.new(&@block).simulate
  end
end

def main
  _ = RankAndFileUnit.new_with_positions(5, Model.new("halberd", [
    Part.new("man", 3, 3, 3, 1, 3, 2, 7, 6, 7, []),
  ], 20, 20, []), 12, [1, 3] => Model.new("champion", [
    Part.new("man", 3, 3, 3, 1, 3, 2, 7, 6, 7, []),
  ], 40, 40, []))
  # 11.times do
  #  r.take_wounds(1)
  #  p r
  # end

  hal = RankAndFileUnit.new_with_positions(10, Model.new("halberd", [
    Part.new("man", 3, 3, 3, 1, 3, 1, 7, 6, 7, []),
  ], 20, 20, []), 40, {}, -40)
  wit = RankAndFileUnit.new_with_positions(7, Model.new("witch elves", [
    Part.new("elf", 4, 3, 3, 1, 5, 2, 7, 7, 7, []),
  ], 20, 20, []), 21, {}, 20)

  simulator = Simulation.new(
    NUMBER_OF_TRIALS,
    TrialRunner.new do
      [
        Marshal.load(Marshal.dump(hal)),
        Marshal.load(Marshal.dump(wit))
      ]
    end
  )

  # puts u.draw
  # puts b.draw
  # puts u.size

  # puts u.number_of_ranks
  # puts u.rank_bonus
  # puts u.positions_occupied
  # puts b.positions_occupied
  # puts compute_offset(b, u)
  # puts compute_offset(u, b)
  # p u.models_in_mm_range(u.convert_coordinate(60), u.convert_coordinate(160))
  # p u.find_targets(b)[0]

  simulator.simulate
  simulator.print_results
end

def compute_offset(unit_with_offset, unit_needing_offset)
  unit_with_offset.mm_width +
    unit_with_offset.offset -
    unit_needing_offset.mm_width
end

main

