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
    defender_matchups = defender.matchups_for_initiative(initiative_value,
                                                         @number, attacker)
    [attacker_matchups, defender_matchups]
  end

  def initiative_steps
    (attacker.initiative_steps(@number) | defender.initiative_steps(@number))
      .sort
  end

  def simulate
    attacker_result = AttackMatchupResult.new(0, 0, 0, 0)
    defender_result = AttackMatchupResult.new(0, 0, 0, 0)
    initiative_steps.reverse_each do |initiative_value|
      all_matchups = build_matchups(initiative_value)
      all_matchups.map! { |matchup_group| matchup_group.map! { |matchup| [matchup, matchup.attack] } }
      all_matchups.each do |results|
        results.map! do |matchup, result|
          matchup.defender.take_wounds(result.unsaved_wounds)
          result
        end
      end
      attacker_result = all_matchups[0].reduce(attacker_result, &:+)
      defender_result = all_matchups[1].reduce(defender_result, &:+)
    end

    #p attacker.positions
    #p defender.positions

    RoundResult.new(
      compute_outcome(attacker, defender, attacker_result, defender_result),
      attacker_result,
      defender_result,
    )
  end

  def compute_outcome(attacker, defender, attacker_result, defender_result)
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
  end
end

