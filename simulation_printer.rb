class SimulationPrinter
  def initialize(*simulations, number_of_trials)
    @simulations      = simulations
    @number_of_trials = number_of_trials
  end

  def print_results
    print_distribution_results("Simulation Statistics", [
      ["Rounds", map_results(&:number_of_rounds)]
    ])

    puts
    puts "Battle Statistics:"
    header = @simulations.reduce([""]) { |a, simulation|
      a + ["simulation ##{a.size}"]
    }
    puts ("%24s" + " %14s" * @simulations.size) % header
    [
      ["Attacker Wins:", attacker_wins],
      ["Defender Wins:", defender_wins],
      ["Attacker Flees:", attacker_flee],
      ["Defender Flees:", defender_flee],
      ["Both Dead:", both_dead],
      ["Favorable for attacker:", favorable_for_attacker],
      ["Favorable for defender:", favorable_for_defender],
    ].each do |line|
      puts ("%24s %5d %7.2f%%" + " %5d %7.2f%% %7.2f%%" * (@simulations.size - 1)) %
        [line[0], *[line[1].first, (line[1].first.to_f / @number_of_trials * 100)],
         *line[1][1..-1].flat_map { |line_result| [line_result, (line_result.to_f / @number_of_trials * 100), (line_result - line[1].first).to_f / line[1].first * 100] }]
    end

    puts
    print_distribution_results("Attacker", [
      ["Trial Wounds", attacker_wounds],
      ["First Round Hits", map_results(&:hits_caused_by_attacker_each_round).map { |v| v.map { |u| u[0] } }],
      ["First Round Wounds", map_results(&:wounds_caused_by_attacker_each_round).map { |v| v.map { |u| u[0] } }],
      ["First Round Unsaved", attacker_wounds_each_round.map {|v| v.map { |u| u[0] } }],
      ["Survivor Models", map_results(&:attacker_survivors).map { |v| v.compact!; v.empty? ? [0] : v }],
    ])

    puts
    print_distribution_results("Defender", [
      ["Trial Wounds", defender_wounds],
      ["First Round Hits", map_results(&:hits_caused_by_defender_each_round).map { |v| v.map { |u| u[0] } }],
      ["First Round Wounds", map_results(&:wounds_caused_by_defender_each_round).map { |v| v.map { |u| u[0] } }],
      ["First Round Unsaved", defender_wounds_each_round.map {|v| v.map { |u| u[0] } }],
      ["Survivor Models", map_results(&:defender_survivors).map { |v| v.compact!; v.empty? ? [0] : v }],
    ])
  end

  def attacker_wins
    sum_results(:attacker_win)
  end

  def defender_wins
    sum_results(:defender_win)
  end

  def attacker_flee
    sum_results(:attacker_flee)
  end

  def defender_flee
    sum_results(:defender_flee)
  end

  def both_dead
    sum_results(:both_dead)
  end

  def favorable_for_attacker
    (0...attacker_wins.size).map do |index|
      attacker_wins[index] + defender_flee[index]
    end
  end

  def favorable_for_defender
    (0...attacker_wins.size).map do |index|
      defender_wins[index] + attacker_flee[index]
    end
  end

  def sum_results(successful_outcomes)
    @simulations.map do |simulation|
      simulation.trial_results.count do |result|
        result.outcome == successful_outcomes
      end
    end
  end

  def map_results(&map_function)
    @simulations.map do |simulation|
      simulation.trial_results.map(&map_function)
    end
  end

  def attacker_wounds
    map_results(&:wounds_caused_by_attacker)
  end

  def defender_wounds
    map_results(&:wounds_caused_by_defender)
  end

  def attacker_wounds_each_round
    map_results(&:unsaved_wounds_caused_by_attacker_each_round)
  end

  def defender_wounds_each_round
    map_results(&:unsaved_wounds_caused_by_defender_each_round)
  end

  def print_distribution_results(name, columns)
    round_to = 2
    max_label_length = [columns.max_by { |col| col[0].length }[0].length, 13].max
    puts "#{name} Statistics:"
    [
      ["", columns.map { |col| col[0] }],
      ["", ["-" * (max_label_length * @simulations.size + @simulations.size)] * columns.size],
      ["Max:", columns.map { |col| col[1].map { |subcol| subcol.max.round(round_to) } }],
      ["Average:", columns.map { |col| col[1].map { |subcol| mean(subcol).round(round_to) } }],
      ["Min:", columns.map { |col| col[1].map { |subcol| subcol.min.round(round_to) } }],
      ["Std. Dev.:", columns.map { |col| col[1].map { |subcol| standard_deviation(subcol, mean(subcol)).round(round_to) } }],
      ["68.2% Range:", columns.map do |col|
        col[1].map do |subcol|
          col_mean = mean(subcol).round(round_to)
          std_dev = standard_deviation(subcol, col_mean).round(round_to)
          "#{(col_mean - std_dev).round(round_to)} - #{(col_mean + std_dev).round(round_to)}"
        end
      end],
      ["95% Range:", columns.map do |col|
        col[1].map do |subcol|
          col_mean = mean(subcol)
          std_dev = standard_deviation(subcol, col_mean)
          "#{(col_mean - 2 * std_dev).round(round_to)} - #{(col_mean + 2 * std_dev).round(round_to)}"
        end
      end],
    ].each { |line|
      puts line[0].rjust(15) + " " + line[1].map { |val|
        if val.is_a?(Array)
          val.map { |v| v.to_s.rjust(max_label_length + 1) }.join("")
        else
          val.to_s.rjust(max_label_length * @simulations.size + @simulations.size)
        end
      }.join(" |")
    }
  end

  def standard_deviation(dist, mean)
    sum_of_squares = dist.reduce(0) { |sum, value| sum + (value - mean) ** 2 }
    Math.sqrt(sum_of_squares.to_f / dist.size)
  end

  def mean(dist)
    dist.inject(0, &:+).to_f / dist.size
  end
end

