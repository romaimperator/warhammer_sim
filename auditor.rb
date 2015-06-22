class Auditor
  def initialize(round_number, attack)
    @round_number = round_number
    @attack       = attack
  end

  def rolls(starting_value)
    call_attack_equipment(mappings(:rolls), starting_value)
  end

  def value_needed(starting_value)
    call_attack_equipment(mappings(:value_needed), starting_value)
  end

  def reroll_values(starting_value, value_number)
    call_attack_equipment(mappings(:reroll_values), starting_value, value_number).uniq
  end

  def mappings(method_name)
    fail NotYetImplemented
  end

  private

  def call_attack_equipment(action_to_call, starting_value, *args)
    @attack.equipment.reduce(starting_value) do |result, item|
      item.public_send(action_to_call, @round_number, result, *args)
    end
  end
end

class PassThroughAuditor
  def rolls(starting_value)
    starting_value
  end

  def value_needed(starting_value)
    starting_value
  end

  def reroll_values(starting_value, value_number)
    starting_value
  end
end
