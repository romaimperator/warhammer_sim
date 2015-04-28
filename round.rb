require_relative 'round_result'
require_relative 'round_stats'
require_relative 'compute_hits'
require_relative 'compute_wounds'
require_relative 'attack_matchup'
require 'pp'

class Round
  attr_accessor :attacker
  attr_accessor :defender

  def initialize(number, _attacker, _defender)
    @number = number
    self.attacker = _attacker
    self.defender = _defender
    self.attacker.round_number = number
    self.defender.round_number = number
  end

  def build_matchups
   #pp attacker.get_matchups(defender)
   #pp defender.get_matchups(attacker)
   #exit
    attacker_parts = attacker.get_all_parts.map do |part|
      part
                       AttackMatchup.new(@number, attacker, defender)
                     end
    defender_parts = defender.parts.map { |part| AttackMatchup.new(@number, defender, attacker) }
    attacker_parts = attacker.get_matchups(defender)
    defender_parts = defender.get_matchups(attacker)
    attacker_parts = attacker_parts.group_by do |matchup|
      initiative = attacker.initiative(defender)
      attacker.for_each_item { |item| initiative = item.initiative(@number, initiative, defender) }
      initiative
    end
    defender_parts = defender_parts.group_by do |matchup|
      initiative = defender.initiative(attacker)
      defender.for_each_item { |item| initiative = item.initiative(@number, initiative, attacker) }
      initiative
    end
    attacker_parts.merge(defender_parts) { |initiative, attacker_part, defender_part| attacker_part + defender_part }
  end

  def simulate
    attacker_attacks = nil#AttackMatchup.new(@number, attacker, defender).number_of_attacks
    defender_attacks = nil#AttackMatchup.new(@number, defender, attacker).number_of_attacks
    attacker_results = []
    defender_results = []
    build_matchups.to_a.each do |initiative_matchups|
      initiative = initiative_matchups[0]
      matchups = initiative_matchups[1]
      matchups.map { |matchup|
        [matchup, matchup.attack]
      }.each { |matchup, result|
        matchup.defender.take_wounds(result.unsaved_wounds)
      }.map { |matchup, result|
        if matchup.attacker == attacker
          attacker_results << result
        else
          defender_results << result
        end
      }
    end

    attacker_result = attacker_results.reduce(AttackMatchupResult.new(0,0,0,0), &:+)
    defender_result = defender_results.reduce(AttackMatchupResult.new(0,0,0,0), &:+)

    outcome = if attacker.dead? && defender.dead?
      BOTH_DEAD
    elsif defender.dead?
      ATTACKER_WIN
    elsif attacker.dead?
      DEFENDER_WIN
    else
      compute_combat_resolution(attacker, defender, attacker_result, defender_result)
    end

    RoundResult.new(
      outcome,
      attacker_result,
      defender_result,
    )
  end

  def attack(attacker, defender)
    AttackMatchup.new(@number, attacker, defender).attack
  end

  def compute_combat_resolution(attacker, defender, attacker_result, defender_result)
    res_difference = attacker.combat_res_earned(attacker_result) - defender.combat_res_earned(defender_result)

    if res_difference > 0
      if defender.roll_break_test(res_difference, attacker.number_of_ranks)
        if attacker.roll_pursuit >= defender.roll_flee
          defender.take_wounds(defender.size)
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
      if attacker.roll_break_test(-res_difference, defender.number_of_ranks)
        if defender.roll_pursuit >= attacker.roll_flee
          attacker.take_wounds(attacker.size)
          DEFENDER_WIN
        else
          ATTACKER_FLEE
        end
      else
        ATTACKER_HOLD
      end
    end
  end
end

