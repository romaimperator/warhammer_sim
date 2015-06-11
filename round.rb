require "pp"

require "round_result"
require "round_stats"
require "compute_hits"
require "compute_wounds"
require "attack_matchup"
require "target_finder"
require "target_strategy"
require "combat_resolution"

# This class is responsible for managing a single round of combat and tracking
# the results.
class Round
  attr_accessor :attacker
  attr_accessor :defender

  def initialize(number, attacker, defender)
    @number   = number
    @attacker = attacker
    @defender = defender
  end

  def build_matchups(initiative_value)
    attacker_matchups = attacker.matchups_for_initiative(initiative_value,
                                                         @number, defender)
    p "Attacker Matchups: #{attacker_matchups}"
    defender_matchups = defender.matchups_for_initiative(initiative_value,
                                                         @number, attacker)
    p "Defender Matchups: #{defender_matchups}"
    [attacker_matchups, defender_matchups]
  end

  def initiative_steps
    (attacker.initiative_steps(@number) | defender.initiative_steps(@number))
      .sort
  end

  def simulate
    attacker_results = []
    defender_results = []
    initiative_steps.reverse_each do |initiative_value|
      all_matchups = build_matchups(initiative_value)
      all_matchups.map! { |matchup_group| matchup_group.map! { |matchup| [matchup, matchup.attack] } }
      attacker_results += all_matchups[0]
      defender_results += all_matchups[1]
    end
    attacker_results.map! do |matchup, result|
      if defender.is_rank_and_file?(matchup.defender)
        defender.take_wounds(result.unsaved_wounds)
      else
        matchup.defender.take_wounds(result.unsaved_wounds)
      end
      result
    end
    defender_results.map! do |matchup, result|
      if attacker.is_rank_and_file?(matchup.defender)
        attacker.take_wounds(result.unsaved_wounds)
      else
        matchup.defender.take_wounds(result.unsaved_wounds)
      end
      result
    end

    attacker_result =
      attacker_results.reduce(AttackMatchupResult.new(0, 0, 0, 0), &:+)
    defender_result =
      defender_results.reduce(AttackMatchupResult.new(0, 0, 0, 0), &:+)

    outcome =
      if attacker.dead? && defender.dead?
        :both_dead
      elsif defender.dead?
        :attacker_win
      elsif attacker.dead?
        :defender_win
      else
        CombatResolution.new(attacker, defender, attacker_result,
                             defender_result).compute
      end

    RoundResult.new(
      outcome,
      attacker_result,
      defender_result,
    )
  end
end

