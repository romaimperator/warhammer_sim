PRNG = Random.new

def roll_die
  PRNG.rand(1..6)
end

def roll_dice(number)
  (1..number).map { |a| roll_die }
end

def roll_dice_and_reroll(number, looking_for_result, values_to_reroll=[])
  roll_dice(number).map { |roll| values_to_reroll.include?(roll) ? roll_die : roll }
end

def count_values_higher_than(rolls, looking_for_result)
  rolls.count { |roll| roll >= looking_for_result }
end

def sum_roll(number)
  roll_dice(number).inject(0, &:+)
end

def sum_roll_discard_highest(number)
  roll_dice(number).sort[0..-2].inject(0, &:+)
end

def sum_roll_discard_lowest(number)
  roll_dice(number).sort[1..-1].inject(0, &:+)
end

