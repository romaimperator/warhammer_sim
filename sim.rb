#!/usr/bin/env ruby

require_relative 'die_roller'
require_relative 'constants'
require_relative 'trial'
require_relative 'round'
require_relative 'model'
require_relative 'unit'

NUMBER_OF_TRIALS = 10000

def main
  trial_runner = Trial.new(Round.new) do
    [Unit.new(Model.new("halberd", 3, 4, 3, 1, 3, 1, 7, 6, 7), 30, 10),
     Unit.new(Model.new("spearman", 3, 3, 3, 1, 3, 1, 7, 6, 7), 30, 10)]
  end

  trial_results = (1..NUMBER_OF_TRIALS).map do |round_number|
    trial_runner.simulate
  end

  results = Hash[trial_runner.results.map do |k,v|
    [k, "#{v}, #{v.to_f / NUMBER_OF_TRIALS}"]
  end]

  round_dist = trial_results.map(&:number_of_rounds)
  puts "Average Rounds: #{mean(round_dist)} Max Rounds: #{round_dist.max} Min Rounds: #{round_dist.min} Std. Dev.: #{standard_deviation(round_dist, mean(round_dist))}"
  puts "Battle statistics:"
  puts "Wins:           #{results[ATTACKER_WIN]}"
  puts "Losses:         #{results[DEFENDER_WIN]}"
  puts "Attacker Flees: #{results[ATTACKER_FLEE]}"
  puts "Defender Flees: #{results[DEFENDER_FLEE]}"
  puts "Both Dead:      #{results[BOTH_DEAD]}"
  puts "Attacker Tests: #{results[ATTACKER_HOLD]}"
  puts "Defender Tests: #{results[DEFENDER_HOLD]}"
end

def standard_deviation(dist, mean)
  squares = dist.map { |value| (value - mean) ** 2 }
  Math.sqrt(squares.inject(0, &:+).to_f / dist.size)
end

def mean(dist)
  dist.inject(0, &:+).to_f / dist.size
end

main

