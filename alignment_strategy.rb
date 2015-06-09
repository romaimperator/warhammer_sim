class AlignmentStrategy
  # Takes an array of Ranks and a value that represents an empty location and
  # yields successive [rank, file] locations that are the next blank spot based
  # on the alignment strategy chosen. Example: The LeftAlignStrategy iterates
  # through each rank front to back and left to right yielding each spot that's
  # empty.
  def self.fill_locations(rank_list, blank_value=nil)
    fail NotYetImplemented
  end

  # Takes an array of Ranks and a value to find the locations of and yields
  # successive [rank, file] locations that are the next spot occupied with the
  # removal_value based on the alignment strategy chosen. Example: The LeftAlignStrategy
  # iterates through each rank back to front and right to left yielding each
  # spot that's occupied by removal_value.
  def self.remove_locations(rank_list, removal_value)
    fail NotYetImplemented
  end
end

# Centers the last rank width odd numbers favoring left side
# Example: 6 models wide with 3 models in the last rank would put "xoooxx"
#          where o are occupied spaces and the up direction is towards the front
class CenterAlignStrategy < AlignmentStrategy
  def self.fill_locations(rank_list, blank_value=nil)
    return to_enum(__callee__, rank_list, blank_value) unless block_given?

    rank_list.each_with_index do |rank, row|
      next_location = rank.size / 2
      increment = -1
      step = 1
      rank.size.times do
        if rank[next_location + 1] == blank_value
          yield [row + 1, next_location + 1]
        end
        next_location = next_location + step * increment
        step += 1
        increment = -increment
      end
    end
  end

  def self.remove_locations(rank_list, removal_value)
    return to_enum(__callee__, rank_list, removal_value) unless block_given?

    rank_list.reverse.each_with_index do |rank, row|
      next_location = rank.size - 1
      increment = 1
      step = rank.size - 1
      rank.size.times do
        if rank[next_location + 1] == removal_value
          yield [rank_list.size - row, next_location + 1]
        end
        next_location = next_location - step * increment
        step -= 1
        increment = -increment
      end
    end
  end
end

class LeftAlignStrategy < AlignmentStrategy
  def self.fill_locations(rank_list, blank_value=nil)
    return to_enum(__callee__, rank_list, blank_value) unless block_given?

    rank_list.each_with_index do |rank, row|
      rank.each_with_index do |value, column|
        if value == blank_value
          yield [row + 1, column + 1]
        end
      end
    end
  end

  def self.remove_locations(rank_list, removal_value)
    return to_enum(__callee__, rank_list, removal_value) unless block_given?

    row = rank_list.size - 1
    while row >= 0
      rank = rank_list[row]
      column = rank.size - 1
      while column >= 0
        value = rank[column + 1]
        if value == removal_value
          yield [row + 1, column + 1]
        end
        column -= 1
      end
      row -= 1
    end
  end
end

class RightAlignStrategy < AlignmentStrategy
  def self.fill_locations(rank_list, blank_value=nil)
    return to_enum(__callee__, rank_list, blank_value) unless block_given?

    rank_list.each_with_index do |rank, row|
      rank.each_with_index do |value, column|
        if value == blank_value
          yield [row + 1, rank.size - column]
        end
      end
    end
  end

  def self.remove_locations(rank_list, removal_value)
    return to_enum(__callee__, rank_list, removal_value) unless block_given?

    rank_list.reverse!.each_with_index do |rank, row|
      rank.reverse!.each_with_index do |value, column|
        if value == removal_value
          yield [rank_list.size - row, column + 1]
        end
      end
      rank.reverse!
    end
    rank_list.reverse!
  end
end

