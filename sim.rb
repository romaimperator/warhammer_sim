#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path("..", __FILE__))

require "die_roller"
require "constants"
require "trial"
require "round"
require "part"
require "model"
require "unit"
require "container_unit"
require "standard_unit"
require "rank_and_file_unit"
require "rank_and_file_model"
require "champion"
require "simulation"
require "simulation_printer"
require "equipment"
require "stats"
require "pp"
require "benchmark"

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

class Copy
  def initialize(object)
    @object = object
  end

  def copy
    Marshal.load(Marshal.dump(@object))
  end
end

NUMBER_OF_TRIALS = 99

class TrialRunner
  def initialize(&block)
    @block = block
  end

  def simulate
    Trial.new(&@block).simulate
  end
end

def main
  # halberd = RankAndFileModel.new("halberd", 20, 20, [Halberd.new],
  #                                Stats.new(3, 3, 3, 1, 3, 1, 7, 6, 7))
  # hal = RankAndFileUnit.new_with_positions(10, halberd, 40, {}, -40, [Standard.new])
 #witch_elf = RankAndFileModel.new("witch elves", 20, 20,
 #                                 [PoisonAttacks.new,
 #                                  RerollMisses.new,
 #                                  ExtraHandWeapon.new,
 #                                  MurderousProwess.new,
 #                                  MinusToHit.new(1),
 #                                  Fear.new,
 #                                  Frenzy.new,],
 #                                 Stats.new(4, 3, 3, 1, 5, 1, 8, 7, 7))
 #ass = Champion.new("assassin", 20, 20,
 #                   [PoisonAttacks.new,
 #                    MurderousProwess.new,
 #                    RerollMisses.new,
 #                    MinusToHit.new(1),
 #                   ],
 #                   Stats.new(9, 4, 3, 2, 10, 3, 8, 7, 7))
 #wit = RankAndFileUnit.new_with_positions(10, witch_elf, 34, {[1, 5] => ass}, 40, [Standard.new])
 #beast = RankAndFileModel.new("beast", 40, 40,
 #                             [RandomAttacks.new(1),
 #                              PoisonAttacks.new,
 #                              StompAttack.new,
 #                             ],
 #                             Stats.new(3, 4, 5, 4, 2, 1, 7, 7, 4))
 #beasts = RankAndFileUnit.new_with_positions(7, beast, 7, {}, -40, [Daemonic.new])

 #simulator = Simulation.new(
 #  NUMBER_OF_TRIALS,
 #  TrialRunner.new do
 #    [
 #      Marshal.load(Marshal.dump(wit)),
 #      Marshal.load(Marshal.dump(beasts))
 #    ]
 #  end
 #)
 #results = simulator.simulate

 #witch_elf = RankAndFileModel.new("witch elves", 20, 20,
 #                                 [PoisonAttacks.new,
 #                                  RerollMisses.new,
 #                                  ExtraHandWeapon.new,
 #                                  MurderousProwess.new,
 #                                  MinusToHit.new(1),
 #                                  Fear.new,
 #                                  Frenzy.new,],
 #                                 Stats.new(4, 3, 3, 1, 5, 1, 8, 7, 7))
 #ass = Champion.new("assassin", 20, 20,
 #                   [PoisonAttacks.new,
 #                    MurderousProwess.new,
 #                    RerollMisses.new,
 #                    MinusToHit.new(1),
 #                   ],
 #                   Stats.new(9, 4, 3, 2, 10, 3, 8, 7, 7))
 #wit = RankAndFileUnit.new_with_positions(10, witch_elf, 34, {}, 40, [Standard.new])
 #beast = RankAndFileModel.new("beast", 40, 40,
 #                             [RandomAttacks.new(1),
 #                              PoisonAttacks.new,
 #                              StompAttack.new,
 #                             ],
 #                             Stats.new(3, 4, 5, 4, 2, 1, 7, 7, 4))
 #beasts = RankAndFileUnit.new_with_positions(7, beast, 7, {}, -40, [Daemonic.new])

 #puts "-" * 50
 #puts " The Second Simulation begins"
 #puts "-" * 50

 #simulator2 = Simulation.new(
 #  NUMBER_OF_TRIALS,
 #  TrialRunner.new do
 #    [
 #      Marshal.load(Marshal.dump(wit)),
 #      Marshal.load(Marshal.dump(beasts))
 #    ]
 #  end
 #)
 #result2 = simulator2.simulate

 #SimulationPrinter.new(results, result2, NUMBER_OF_TRIALS).print_results
  #simulator.print_results

  witch_elf = Copy.new(RankAndFileModel.new("witch elves", 20, 20,
                                   [PoisonAttacks.new,
                                    RerollMisses.new,
                                    ExtraHandWeapon.new,
                                    MurderousProwess.new,
                                    MinusToHit.new(1),
                                    Fear.new,
                                    Frenzy.new,],
                                   Stats.new(4, 3, 3, 1, 5, 1, 8, 7, 7)))
  ass = Copy.new(Champion.new("assassin", 20, 20,
                     [PoisonAttacks.new,
                      MurderousProwess.new,
                      RerollMisses.new,
                      MinusToHit.new(1),
                     ],
                     Stats.new(9, 4, 3, 2, 10, 3, 8, 7, 7)))
  wit = RankAndFileUnit.new_with_positions(10, witch_elf.copy, 34, {[1, 5] => ass.copy}, 40, [Standard.new])
  wit2 = RankAndFileUnit.new_with_positions(10, witch_elf.copy, 34, {}, 40, [Standard.new])

  beast = Copy.new(RankAndFileModel.new("beast", 40, 40,
                               [RandomAttacks.new(1),
                                PoisonAttacks.new,
                                StompAttack.new,
                               ],
                               Stats.new(3, 4, 5, 4, 2, 1, 7, 7, 4)))
  beasts = RankAndFileUnit.new_with_positions(7, beast.copy, 7, {}, -40, [Daemonic.new])

  simulations = [
    [wit, beasts],
    [beasts, wit],
  ]

  index = 0
  results = simulations.map do |(attacker, defender)|
    puts "-" * 50
    puts "Starting simulation #{index += 1}"
    puts "-" * 50
    Simulation.new(
      NUMBER_OF_TRIALS,
      TrialRunner.new do
        [
          Marshal.load(Marshal.dump(attacker)),
          Marshal.load(Marshal.dump(defender))
        ]
      end
    ).simulate
  end

  SimulationPrinter.new(*results, NUMBER_OF_TRIALS).print_results
end

def compute_offset(unit_with_offset, unit_needing_offset)
  unit_with_offset.mm_width +
    unit_with_offset.offset -
    unit_needing_offset.mm_width
end

main

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

 ##simulator.print_results
