#!/usr/bin/env ruby

require_relative 'die_roller'
require_relative 'constants'
require_relative 'trial'
require_relative 'round'
require_relative 'model'
require_relative 'unit'
require_relative 'simulation'
require_relative 'equipment/halberd'
require_relative 'equipment/spear'
require_relative 'equipment/sword_of_striking'
require_relative 'equipment/reroll_misses'
require_relative 'equipment/reroll_wounds'
require_relative 'equipment/murderous_prowess'
require_relative 'equipment/poison_attacks'

NUMBER_OF_TRIALS = 10000

def main
  simulator = Simulation.new(
    NUMBER_OF_TRIALS,
    Trial.new do
      [
        Unit.new(
          Model.new("witch elves", 3, 3, 3, 1, 3, 4, 7, 7, 5, 20, 20), 20, 5, [
            PoisonAttacks.new,
            RerollMisses.new,
            RerollWounds.new,
            MurderousProwess.new,
          ]
        ),
        Unit.new(
          Model.new("halberd", 3, 3, 3, 1, 3, 1, 7, 6, 7, 20, 20), 40, 10, [
            Halberd.new,
          ]
        )
      ]
    end
  )

  simulator.simulate
  simulator.print_results
end

main

