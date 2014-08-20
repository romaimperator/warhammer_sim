#!/usr/bin/env ruby

require_relative 'die_roller'
require_relative 'constants'
require_relative 'trial'
require_relative 'round'
require_relative 'model'
require_relative 'unit'
require_relative 'simulation'

NUMBER_OF_TRIALS = 10000

def main
  simulator = Simulation.new(
    NUMBER_OF_TRIALS,
    Trial.new do
      [
        Unit.new(
          Model.new("halberd", 3, 3, 3, 1, 3, 1, 7, 6, 7), 40, 10
        ),
        Unit.new(
          Model.new("spearman", 3, 3, 3, 1, 3, 1, 7, 6, 7), 40, 10
        )
      ]
    end
  )

  simulator.simulate
  simulator.print_results
end

main

