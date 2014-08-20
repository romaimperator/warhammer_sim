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
    @trial_results.map(&:wounds_caused_by_attacker_each_round).flatten
  end

  def defender_wounds_each_round
    @trial_results.map(&:wounds_caused_by_defender_each_round).flatten
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
      ["Wins:", attacker_wins],
      ["Losses:", defender_wins],
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
    print_distribution_results("Attacker each round", "Wounds", attacker_wounds_each_round)
    puts
    print_distribution_results("Defender each round", "Wounds", defender_wounds_each_round)

    aw = attacker_wounds_each_round.group_by { |i| i }.map { |k,v| [k, v.size] }.sort_by { |i| i[0] }
    dw = defender_wounds_each_round.group_by { |i| i }.map { |k,v| [k, v.size] }.sort_by { |i| i[0] }
    require 'gnuplot'
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|

        plot.terminal "gif"
        plot.output File.expand_path("../attacker_wounds_per_round.gif", __FILE__)
        plot.title  "Attacker wounds per round"
        plot.xlabel "wounds per round"
        plot.ylabel "rounds"
        plot.xtics  "0, 2"
        plot.xtics  "scale 2, 1"
        plot.mxtics "2"

        x = aw.map { |aw| aw[0] }
        y = aw.map { |aw| aw[1] }

        plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
          ds.with = "linespoints"
          ds.notitle
        end
      end
    end

    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        plot.terminal "gif"
        plot.output File.expand_path("../defender_wounds_per_round.gif", __FILE__)
        plot.title  "Defender wounds per round"
        plot.xlabel "wounds per round"
        plot.ylabel "rounds"
        plot.xtics  "0, 2"
        plot.xtics  "scale 2, 1"
        plot.mxtics "2"

        x = dw.map { |dw| dw[0] }
        y = dw.map { |dw| dw[1] }

        plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
          ds.with = "linespoints"
          ds.notitle
        end
      end
    end

  end

  def print_distribution_results(name, measurment_name, dist)
    puts "#{name} Statistics:"
    [
      ["Average #{measurment_name}:", mean(dist)],
      ["Max #{measurment_name}:", dist.max],
      ["Min #{measurment_name}:", dist.min],
      ["Std. Dev.:", standard_deviation(dist, mean(dist))],
    ].each { |line| puts line[0].rjust(15) + " " + "#{line[1].round(3)}".rjust(7) }
  end
end

