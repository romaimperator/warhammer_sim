require 'rank'

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
    if rank <= @the_grid.size
      @the_grid[rank - 1][file] = new_value
    else
      while rank > @the_grid.size
        add_new_rank
      end
      @the_grid[rank - 1][file] = new_value
    end
  end

  def fill!(new_value, number_to_fill=@files)
    empty_spaces = @alignment_strategy.fill_locations(@the_grid).count
    if empty_spaces < number_to_fill
      ((number_to_fill - empty_spaces).to_f / @files).ceil.times do
        add_new_rank
      end
    end
    @alignment_strategy.fill_locations(@the_grid) do |rank, file|
      if number_to_fill > 0
        set(file, rank, new_value)
        number_to_fill -= 1
      else
        break
      end
    end
  end

  def unfill!(removal_value, number_to_remove)
    @alignment_strategy.remove_locations(@the_grid, removal_value) do |rank, file|
      if number_to_remove > 0
        set(file, rank, nil)
        number_to_remove -= 1
      else
        break
      end
    end
    remove_empty_ranks
  end

  def count_in_rank(rank, value)
    @the_grid[rank - 1].value_count(value)
  end

  def ==(other)
    @the_grid == other.the_grid
  end

  def each_position
    return to_enum(__callee__) unless block_given?

    @the_grid.each_with_index do |rank, rank_number|
      rank.each_with_index do |file, file_number|
        if file
          yield rank_number + 1, file_number + 1, file
        end
      end
    end
  end

  def find_each(find_value)
    return to_enum(__callee__, find_value) unless block_given?

    @the_grid.each_with_index do |rank, rank_number|
      rank.each_with_index do |file, file_number|
        if file == find_value
          yield rank_number + 1, file_number + 1, file
        end
      end
    end
  end

  private

  def add_new_rank
    @ranks += 1
    @the_grid << Rank.new(@files, [])
  end

  def remove_empty_ranks
    @the_grid = @the_grid.take_while { |rank| !rank.empty? }
    @ranks    = @the_grid.size
  end
end
