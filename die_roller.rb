PRNG = Random.new

def roll_die
  PRNG.rand(1..6)
end

def sum_roll(number)
  (1..number).map { |a| roll_die}.inject(0, &:+)
end

def roll_dice(number, looking_for_result)
  count = 0
  (1..number).map { |a| roll_die }.each do |result|
    if result >= looking_for_result
      count += 1
    end
  end
  count
end

