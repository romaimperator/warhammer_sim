class AlignmentStrategy
  def self.align_rank(new_last_rank, blank_space_count)
    fail NotYetImplemented
  end
end

# Centers the last rank width odd numbers favoring left side
# Example: 6 models wide with 3 models in the last rank would put "xoooxx"
#          where o are occupied spaces and the up direction is towards the front
class CenterAlignStrategy < AlignmentStrategy
  def self.align_rank(new_last_rank, blank_space_count)
    width = new_last_rank.size
    left_unoccupied_spaces = blank_space_count / 2
    new_last_rank.rotate(-left_unoccupied_spaces)
  end
end

class LeftAlignStrategy < AlignmentStrategy
  def self.align_rank(new_last_rank, blank_space_count)
    new_last_rank
  end
end

class RightAlignStrategy < AlignmentStrategy
  def self.align_rank(new_last_rank, blank_space_count)
    width = new_last_rank.size
    new_last_rank.rotate(width - blank_space_count)
  end
end

