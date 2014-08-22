require_relative 'round_result'
require_relative 'round_stats'
require_relative 'compute_hits'
require_relative 'compute_wounds'
require_relative 'attack_matchup'

class Round
  def initialize(number)
    @number = number
  end

  def simulate(attacker, defender)
    attacker_attacks = attacker.attacks(@number, defender)
    defender_attacks = defender.attacks(@number, attacker)
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

