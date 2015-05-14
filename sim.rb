#!/usr/bin/env ruby

require_relative 'die_roller'
require_relative 'constants'
require_relative 'trial'
require_relative 'round'
require_relative 'part'
require_relative 'model'
require_relative 'unit'
require_relative 'standard_unit'
require_relative 'rank_and_file_unit'
require_relative 'simulation'
require_relative 'equipment/halberd'
require_relative 'equipment/spear'
require_relative 'equipment/sword_of_striking'
require_relative 'equipment/reroll_misses'
require_relative 'equipment/reroll_wounds'
require_relative 'equipment/murderous_prowess'
require_relative 'equipment/poison_attacks'
require_relative 'equipment/extra_hand_weapon'

NUMBER_OF_TRIALS = 100

def main
  p RankAndFileUnit.new(5, Model.new("halberd", [
              Part.new("man", 3, 3, 3, 1, 3, 2, 7, 6, 7, []),
  ], 20, 20, []), 11, [1, 3] => Model.new("champion", [
              Part.new("man", 3, 3, 3, 1, 3, 2, 7, 6, 7, []),
            ], 40, 40, [])).inspect
  exit

    u = StandardUnit.new(
          Model.new("halberd", [
            Part.new("man", 3, 3, 3, 1, 3, 1, 7, 6, 7, []),
          ], 20, 20, []), {
            [1, 5] => Model.new("champion", [
              Part.new("man", 3, 3, 3, 1, 3, 2, 7, 6, 7, []),
            ], 20, 20, []),
          },
          40,
          10,
          -40, [
            Halberd.new,
          ]
        )
    s = StandardUnit.new(
          Model.new("sword", [
            Part.new("man", 4, 3, 3, 1, 3, 1, 7, 5, 6, []),
          ], 20, 20, []), {
            [1, 5] => Model.new("champion", [
              Part.new("man", 4, 3, 3, 1, 3, 2, 7, 5, 6, []),
            ], 20, 20, []),
          },
          40,
          10,
          -40, [
            #Halberd.new,
          ]
    )
    b = StandardUnit.new(
          Model.new("witch elves", [
            Part.new("elf", 4, 3, 3, 1, 5, 2, 7, 7, 7, [])
          ], 20, 20, []), {}, 20, 5, 60, [
            ExtraHandWeapon.new,
            PoisonAttacks.new,
            #RerollMisses.new,
            #RerollWounds.new,
            MurderousProwess.new,
          ]
        )

  simulator = Simulation.new(
    NUMBER_OF_TRIALS,
    Trial.new do [
        Marshal.load(Marshal.dump(b)),
        Marshal.load(Marshal.dump(u))
      ]
    end
  )

  puts u.draw
  puts b.draw
  puts u.size

  puts u.number_of_ranks
  puts u.rank_bonus
  puts u.positions_occupied
  puts b.positions_occupied
  puts compute_offset(b, u)
  puts compute_offset(u, b)
  p u.models_in_mm_range(u.convert_coordinate(60), u.convert_coordinate(160))
  p u.find_targets(b)[0]
  #exit

  simulator.simulate
  simulator.print_results
end

def compute_offset(unit_with_offset, unit_needing_offset)
  unit_with_offset.mm_width + unit_with_offset.offset -
    unit_needing_offset.mm_width
end

main

