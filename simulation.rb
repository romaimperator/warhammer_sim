class Simulation
  def initialize(number_of_trials, trial_runner)
    @number_of_trials = number_of_trials
    @trial_runner = trial_runner
  end

  def simulate
    @trial_results = (1..@number_of_trials).map do |round_number|
      @trial_runner.simulate
    end
  end

  def attacker_wins
    sum_results(ATTACKER_WIN)
  end

  def defender_wins
    sum_results(DEFENDER_WIN)
  end

  def attacker_flee
    sum_results(ATTACKER_FLEE)
  end

  def defender_flee
    sum_results(DEFENDER_FLEE)
  end

  def both_dead
    sum_results(BOTH_DEAD)
  end

  def sum_results(successful_outcomes)
    successful_outcomes = [successful_outcomes] unless successful_outcomes.is_a?(Array)
    @trial_results.inject(0) do |sum, result|
      if successful_outcomes.include?(result.outcome)
        sum + 1
      else
        sum
      end
    end
  end

  def attacker_wounds
    @trial_results.map(&:wounds_caused_by_attacker)
  end

  def defender_wounds
    @trial_results.map(&:wounds_caused_by_defender)
  end

  def attacker_wounds_each_round
    @trial_results.map(&:wounds_caused_by_attacker_each_round)
  end

  def defender_wounds_each_round
    @trial_results.map(&:wounds_caused_by_defender_each_round)
  end

  def standard_deviation(dist, mean)
    squares = dist.map { |value| (value - mean) ** 2 }
    Math.sqrt(squares.inject(0, &:+).to_f / dist.size)
  end

  def mean(dist)
    dist.inject(0, &:+).to_f / dist.size
  end

  def print_results
    print_distribution_results("Round", "Rounds", @trial_results.map(&:number_of_rounds))
    puts
    puts "Battle Statistics:"
    [
      ["Attacker Wins:", attacker_wins],
      ["Defender Wins:", defender_wins],
      ["Attacker Flees:", attacker_flee],
      ["Defender Flees:", defender_flee],
      ["Both Dead:", both_dead],
      ["Favorable for attacker:", attacker_wins + defender_flee],
      ["Favorable for defender:", defender_wins + attacker_flee],
    ].each { |line| puts line[0].rjust(24) + " " + "#{line[1]}".rjust(5) + " " + "#{line[1].to_f / @number_of_trials}".rjust(7) }
    puts
    print_distribution_results("Attacker", "Wounds", attacker_wounds)
    puts
    print_distribution_results("Defender", "Wounds", defender_wounds)
    puts
    print_distribution_results("Attacker first round", "Wounds", attacker_wounds_each_round.map { |v| v[0] })
    puts
    print_distribution_results("Defender first round", "Wounds", defender_wounds_each_round.map { |v| v[0] })

    #aw = attacker_wounds_each_round.flatten.group_by { |i| i }.map { |k,v| [k, v.size] }.sort_by { |i| i[0] }
    #dw = defender_wounds_each_round.flatten.group_by { |i| i }.map { |k,v| [k, v.size] }.sort_by { |i| i[0] }
    require 'gnuplot'
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|

        plot.terminal "gif"
        plot.output File.expand_path("../attacker_wounds_per_round.gif", __FILE__)
        plot.title  "Attacker wounds first round"
        plot.xlabel "wounds first round"
        plot.ylabel "trials"
        plot.xtics  "0, 2"
        plot.xtics  "scale 2, 1"
        plot.mxtics "2"

        plot.data << Gnuplot::DataSet.new( get_dataset_for_round(attacker_wounds_each_round, 1) ) do |ds|
          ds.with = "linespoints"
          ds.title = "First Round"
        end

        plot.data << Gnuplot::DataSet.new( get_dataset_for_round(attacker_wounds_each_round, 2) ) do |ds|
          ds.with = "linespoints"
          ds.title = "Second Round"
        end

        plot.data << Gnuplot::DataSet.new( get_dataset_for_round(attacker_wounds_each_round, 3) ) do |ds|
          ds.with = "linespoints"
          ds.title = "Third Round"
        end

        plot.data << Gnuplot::DataSet.new( get_dataset_for_round(attacker_wounds_each_round, 4) ) do |ds|
          ds.with = "linespoints"
          ds.title = "Fourth Round"
        end

        plot.data << Gnuplot::DataSet.new( get_dataset_for_round(attacker_wounds_each_round, 5) ) do |ds|
          ds.with = "linespoints"
          ds.title = "Fifth Round"
        end

        plot.data << Gnuplot::DataSet.new( get_dataset_for_round(attacker_wounds_each_round, 6) ) do |ds|
          ds.with = "linespoints"
          ds.title = "Sixth Round"
        end
      end
    end

    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        plot.terminal "gif"
        plot.output File.expand_path("../defender_wounds_per_round.gif", __FILE__)
        plot.title  "Defender wounds first round"
        plot.xlabel "wounds first round"
        plot.ylabel "trials"
        plot.xtics  "0, 2"
        plot.xtics  "scale 2, 1"
        plot.mxtics "2"

        plot.data << Gnuplot::DataSet.new( get_dataset_for_round(defender_wounds_each_round, 1) ) do |ds|
          ds.with = "linespoints"
          ds.title = "First Round"
        end

        plot.data << Gnuplot::DataSet.new( get_dataset_for_round(defender_wounds_each_round, 2) ) do |ds|
          ds.with = "linespoints"
          ds.title = "Second Round"
        end

        plot.data << Gnuplot::DataSet.new( get_dataset_for_round(defender_wounds_each_round, 3) ) do |ds|
          ds.with = "linespoints"
          ds.title = "Third Round"
        end

        plot.data << Gnuplot::DataSet.new( get_dataset_for_round(defender_wounds_each_round, 4) ) do |ds|
          ds.with = "linespoints"
          ds.title = "Fourth Round"
        end

        plot.data << Gnuplot::DataSet.new( get_dataset_for_round(defender_wounds_each_round, 5) ) do |ds|
          ds.with = "linespoints"
          ds.title = "Fifth Round"
        end

        plot.data << Gnuplot::DataSet.new( get_dataset_for_round(defender_wounds_each_round, 6) ) do |ds|
          ds.with = "linespoints"
          ds.title = "Sixth Round"
        end
      end
    end

  end

  def get_data_for_round(data_matrix, round)
    data_matrix.map { |v| v[round - 1] }.select { |i| not i.nil? }.group_by { |i| i }.map { |k,v| [k, v.size] }.sort_by { |i| i[0] }
  end

  def get_dataset_for_round(data_matrix, round)
    data = get_data_for_round(data_matrix, round)
    [
      data.map { |i| i[0] },
      data.map { |i| i[1] },
    ]
  end

  def print_distribution_results(name, measurment_name, dist)
    puts "#{name} Statistics:"
    [
      ["Average #{measurment_name}:", mean(dist)],
      ["Max #{measurment_name}:", dist.max],
      ["Min #{measurment_name}:", dist.min],
      ["Std. Dev.:", standard_deviation(dist, mean(dist))],
    ].each { |line| puts line[0].rjust(15) + " " + "#{line[1].round(3)}".rjust(7) }
    puts "68.2% Range:".rjust(15) + " " + "#{(mean(dist) - standard_deviation(dist, mean(dist))).round(3)} - #{(mean(dist) + standard_deviation(dist, mean(dist))).round(3)}"
    puts "95% Range:".rjust(15) + " " + "#{(mean(dist) - 2 * standard_deviation(dist, mean(dist))).round(3)} - #{(mean(dist) + 2 * standard_deviation(dist, mean(dist))).round(3)}"
  end
end

