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

NUMBER_OF_TRIALS = 10000

def main
  simulator = Simulation.new(
    NUMBER_OF_TRIALS,
    Trial.new do
      [
        Unit.new(
          Model.new("halberd", 3, 3, 3, 1, 3, 1, 7, 6, 7), 40, 10, [
            Halberd.new,
          ]
        ),
        Unit.new(
          Model.new("spearman", 3, 3, 3, 1, 3, 1, 7, 6, 7), 40, 10, [
            FootSpear.new,
          ]
        )
      ]
    end
  )

  simulator.simulate
  simulator.print_results
end

main

