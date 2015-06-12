require_relative 'alignment_strategy'

class Rank
  attr_reader :rank,
              :files

  def initialize(files, values=[])
    @files = files
    @empty_spaces = files - values.size
    @rank = fill_blank_spaces(values)
  end

  def [](file_position)
    fail IndexError, "Index is out of bounds: #{file_position}" if file_position > @files || file_position <= 0
    @rank[file_position - 1]
  end

  def []=(file_position, value)
    fail IndexError, "Index is out of bounds: #{file_position}" if file_position > @files || file_position <= 0
    adjust_empty_spaces(file_position - 1, value)
    @rank[file_position - 1] = value
  end

  def adjust_empty_spaces(file_position, value)
    if value != nil && @rank[file_position] == nil
      @empty_spaces -= 1
    elsif value == nil && @rank[file_position] != nil
      @empty_spaces += 1
    else
      @empty_spaces
    end
  end

  def each_with_index(&block)
    @rank.each_with_index(&block)
  end

  def each(&block)
    @rank.each(&block)
  end

  def reverse!
    @rank.reverse!
  end

  def size
    @files
  end

  def empty?
    value_count(nil) == @files
  end

  def fill_blank_spaces(values)
    values + [nil] * @empty_spaces
  end

  def fill!(new_value, number_to_fill=@files)
    @rank.map! do |value|
      if value == nil && number_to_fill > 0
        number_to_fill -= 1
        @empty_spaces -= 1
        new_value
      else
        value
      end
    end
    number_to_fill
  end

  def ==(other)
    @rank == other.rank && @files == other.files
  end

  def value_count(value)
    @rank.count(value)
  end
end

