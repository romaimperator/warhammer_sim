#!/usr/bin/env ruby

require_relative 'die_roller'
require_relative 'constants'
require_relative 'round'
require_relative 'model'
require_relative 'unit'

NUMBER_OF_TRIALS = 10000

def main
  round_runner = Round.new do
    [Unit.new(Model.new("halberd", 3, 4, 3, 1, 3, 1, 7, 6, 7), 30, 10),
     Unit.new(Model.new("spearman", 3, 3, 3, 1, 3, 1, 7, 6, 7), 30, 10)]
  end

  round_dist = (1..NUMBER_OF_TRIALS).map do |round_number|
    round_runner.simulate
  end

  results = Hash[round_runner.results.map do |k,v|
    [k, "#{v}, #{v.to_f / NUMBER_OF_TRIALS}"]
  end]

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

def simulate_round(attacker, defender)
  if attacker.initiative > defender.initiative || attacker.strike_first?
    defender.take_wounds(attack(attacker, defender))
    attacker.take_wounds(attack(defender, attacker))
  elsif defender.initiative > attacker.initiative || defender.strike_first?
    attacker.take_wounds(attack(defender, attacker))
    defender.take_wounds(attack(attacker, defender))
  else
    attacker_caused_wounds = attack(attacker, defender)
    defender_caused_wounds = attack(defender, attacker)
    attacker.take_wounds(defender_caused_wounds)
    defender.take_wounds(attacker_caused_wounds)
  end

  if attacker.dead? && defender.dead?
    BOTH_DEAD
  elsif defender.dead?
    ATTACKER_WIN
  elsif attacker.dead?
    DEFENDER_WIN
  else
    compute_combat_resolution(attacker, defender)
  end
end

def attack(attacker, defender)
  hits = attacker.roll_hits(defender)
  wounds = attacker.roll_wounds(hits, defender)
  unsaved_wounds = defender.roll_saves(wounds, attacker.strength)
  attacker.wounds_caused = unsaved_wounds
end

def compute_combat_resolution(attacker, defender)
  res_difference = attacker.combat_res_earned - defender.combat_res_earned

  if res_difference > 0
    if defender.roll_break_test(res_difference)
      if attacker.roll_pursuit >= defender.roll_flee
        ATTACKER_WIN
      else
        DEFENDER_FLEE
      end
    else
      DEFENDER_HOLD
    end
  elsif res_difference == 0
    TIE
  else
    if attacker.roll_break_test(-res_difference)
      if defender.roll_pursuit >= attacker.roll_flee
        DEFENDER_WIN
      else
        ATTACKER_FLEE
      end
    else
      ATTACKER_HOLD
    end
  end
end

main

