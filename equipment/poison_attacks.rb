class PoisonAttacks < Equipment
  def initialize
    super
    @poison_hits = 0
  end

  def roll_hits(round_number, rolls)
    @poison_hits = rolls.select { |i| i == 6 }
    rolls.reject { |i| i == 6 }
  end

  def roll_wounds(round_number, rolls)
    rolls + @poison_hits
  end
end

