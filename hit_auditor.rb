class HitAuditor
  def initialize(round_number, attack)
    @round_number = round_number
    @attack       = attack
  end

  def roll_hits(starting_value)
    call_attack_equipment(:roll_hits, starting_value)
  end

  def hit_needed(starting_value)
    call_attack_equipment(:hit_needed, starting_value)
  end

  def hit_reroll_values(starting_value, to_hit_number)
    call_attack_equipment(:hit_reroll_values, starting_value, to_hit_number).uniq
  end

  private

  def call_attack_equipment(action_to_call, starting_value, *args)
    @attack.equipment.reduce(starting_value) do |result, item|
      item.public_send(action_to_call, @round_number, result, *args)
    end
  end
end

