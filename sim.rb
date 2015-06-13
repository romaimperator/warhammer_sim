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
require "rank_and_file_model"
require "champion"
require "simulation"
require "simulation_printer"
require "equipment"
require "stats"

include Equipment

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

NUMBER_OF_TRIALS = 5_000

class TrialRunner
  def initialize(&block)
    @block = block
  end

  def simulate
    Trial.new(&@block).simulate
  end
end

def main
 # _ = RankAndFileUnit.new_with_positions(5, Model.new("halberd", [
 #   Part.new("man", 3, 3, 3, 1, 3, 2, 7, 6, 7, []),
 # ], 20, 20, []), 12, [1, 3] => Model.new("champion", [
 #   Part.new("man", 3, 3, 3, 1, 3, 2, 7, 6, 7, []),
 # ], 40, 40, []))
  # 11.times do
  #  r.take_wounds(1)
  #  p r
  # end

  halberd = RankAndFileModel.new("halberd", 20, 20, [Halberd.new],
                                 Stats.new(3, 3, 3, 1, 3, 1, 7, 6, 7))
  hal = RankAndFileUnit.new_with_positions(10, halberd, 40, {}, -40, [Standard.new])
  witch_elf = RankAndFileModel.new("witch elves", 20, 20,
                                   [PoisonAttacks.new,
                                    RerollMisses.new,
                                    ExtraHandWeapon.new,
                                    MurderousProwess.new],
                                   Stats.new(4, 3, 3, 1, 5, 2, 7, 7, 7))
  wit = RankAndFileUnit.new_with_positions(7, witch_elf, 21, {}, 20, [Standard.new])

  simulator = Simulation.new(
    NUMBER_OF_TRIALS,
    TrialRunner.new do
      [
        Marshal.load(Marshal.dump(hal)),
        Marshal.load(Marshal.dump(wit))
      ]
    end
  )
  results = simulator.simulate

  #champ   = Champion.new("champ", 20, 20, [Halberd.new], Stats.new(3, 3, 3, 1, 3, 2, 7, 6, 7))
  halberd2 = RankAndFileModel.new("halberd", 20, 20, [Halberd.new],
                                 Stats.new(3, 3, 3, 1, 3, 1, 7, 6, 7))
  hal2 = RankAndFileUnit.new_with_positions(10, halberd2, 40, {}, -40, [Standard.new])
  witch_elf2 = RankAndFileModel.new("witch elves", 20, 20,
                                   [PoisonAttacks.new,
                                    RerollMisses.new,
                                    ExtraHandWeapon.new,
                                    MurderousProwess.new],
                                   Stats.new(4, 3, 3, 1, 5, 2, 7, 7, 7))
  wit2 = RankAndFileUnit.new_with_positions(7, witch_elf2, 21, {}, 20, [Standard.new])

  simulator2 = Simulation.new(
    NUMBER_OF_TRIALS,
    TrialRunner.new do
      [
        Marshal.load(Marshal.dump(hal2)),
        Marshal.load(Marshal.dump(wit2))
      ]
    end
  )
  result2 = simulator2.simulate

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

  SimulationPrinter.new(results, result2, NUMBER_OF_TRIALS).print_results
  #simulator.print_results
end

def compute_offset(unit_with_offset, unit_needing_offset)
  unit_with_offset.mm_width +
    unit_with_offset.offset -
    unit_needing_offset.mm_width
end

main

