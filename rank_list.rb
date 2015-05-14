require_relative 'rank'

class RankList
  attr_reader :the_grid

  def initialize(files, ranks, alignment_strategy=CenterAlignStrategy)
    @files              = files
    @ranks              = ranks
    @the_grid           = ranks.times.map { Rank.new(files, []) }
    @alignment_strategy = alignment_strategy
  end

  def at(file, rank)
    @the_grid[rank - 1][file]
  end

  def set(file, rank, new_value)
    @the_grid[rank - 1][file] = new_value
  end

  def fill!(new_value, number_to_fill=@files)
    @the_grid.each do |rank|
      number_to_fill = rank.fill!(new_value, number_to_fill)
      break if number_to_fill <= 0
    end
    if number_to_fill > 0
      @the_grid << Rank.new(@files)
      fill!(new_value, number_to_fill)
    else
      @the_grid.last.align(@alignment_strategy)
    end
  end

  def count_in_rank(rank, value)
    @the_grid[rank - 1].value_count(value)
  end
end

