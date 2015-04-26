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
    build_matchups.to_a.each do |initiative_matchups|
      initiative = initiative_matchups[0]
      matchups = initiative_matchups[1]
      matchups.map do |matchup|
        [matchup, matchup.attack]
      end.each { |matchup| matchup[0].defender.take_wounds(matchup[1]) }
    end

    outcome = if attacker.dead? && defender.dead?
      BOTH_DEAD
    elsif defender.dead?
      ATTACKER_WIN
    elsif attacker.dead?
      DEFENDER_WIN
    else
      compute_combat_resolution(attacker, defender)
    end

    RoundResult.new(
      outcome,
      RoundStats.new(attacker_attacks, attacker.hits, attacker.wounds_caused, attacker.unsaved_wounds),
      RoundStats.new(defender_attacks, defender.hits, defender.wounds_caused, defender.unsaved_wounds)
    )
  end

  def attack(attacker, defender)
    AttackMatchup.new(@number, attacker, defender).attack
  end

  def compute_combat_resolution(attacker, defender)
    res_difference = attacker.combat_res_earned - defender.combat_res_earned

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

