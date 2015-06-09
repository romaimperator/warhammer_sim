AttackMatchupResult = Struct.new(:attacks,
                                 :hits,
                                 :wounds_caused,
                                 :unsaved_wounds) do
  def hit_percentage
    compute_percentage(hits, attacks)
  end

  def wound_percentage
    compute_percentage(wounds_caused, hits)
  end

  def unsaved_percentage
    compute_percentage(unsaved_wounds, wounds_caused)
  end

  def +(other)
    fail ArgumentError unless other.is_a?(AttackMatchupResult)

    AttackMatchupResult.new(attacks + other.attacks,
                            hits + other.hits,
                            wounds_caused + other.wounds_caused,
                            unsaved_wounds + other.unsaved_wounds)
  end

  private

  def compute_percentage(amount, out_of)
    amount.to_f / out_of * 100
  end
end

