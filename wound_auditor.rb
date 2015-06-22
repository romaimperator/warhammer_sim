class WoundAuditor
  def initialize(round_number, attack)
    @round_number = round_number
    @attack       = attack
  end

  def roll_wounds(hits)
    call_attack_equipment(:roll_wounds, hits)
  end

  def wound_needed(roll_needed)
    call_attack_equipment(:wound_needed, roll_needed)
  end

  def wound_reroll_values(starting_value, wound_needed)
    call_attack_equipment(:wound_reroll_values, starting_value, wound_needed).uniq
  end

  private

  def call_attack_equipment(action_to_call, starting_value, *args)
    @attack.equipment.reduce(starting_value) do |result, item|
      item.public_send(action_to_call, @round_number, result, *args)
    end
  end
end

